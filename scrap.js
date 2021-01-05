const {chromium} = require('playwright');
const ObjectsToCsv = require('objects-to-csv');
const fs = require('fs');

const homePage = 'https://www.sec.gov/Archives/edgar/full-index/';
(async () => {
    try{
        const browser = await chromium.launch({headless: false});
        const context = await browser.newContext();
        const page = await context.newPage();

        // scrap folders by year
        await page.goto(homePage);
        var folderLinks = await page.evaluate(() => {
            let linkDict = {};
            let table = document.querySelectorAll("table tr");
            table = [].slice.call(table, 1);    // [https://stackoverflow.com/questions/6545379/can-we-directly-remove-nodes-from-a-nodelist]
            table.forEach((ele) => {
                let linkNode = ele.firstElementChild;
                let linkRef = window.location.href + linkNode.querySelector('a').getAttribute('href');
                let linkName = linkNode.innerText;
                if((linkName.length == 4 && parseInt(linkName, 10) > 2011) || linkName === 'crawler.idx'){ // crawler.idx is for 2021 QTR1
                    linkDict[linkName] = linkRef;   
                }
            });
            return linkDict;
        });

        // scrap folders by quarters
        // why forEach is not used [https://stackoverflow.com/questions/37576685/using-async-await-with-a-foreach-loop]
        var links = {};
        for(var yearLinkNode in folderLinks){
            let link = folderLinks[yearLinkNode];
            if(!link.includes('crawler.idx')){
                await page.goto(link);
                await page.waitForSelector('table tr');
                var data = await page.evaluate(({yearLinkNode, link}) => {
                    let linkDict = {};
                    let table = document.querySelectorAll('table tr');
                    table = [].slice.call(table, 1);
                    table.forEach((ele) => {
                        let linkNode = ele.firstElementChild;
                        let linkName = linkNode.innerText;
                        let linkRef = window.location.href + linkNode.querySelector('a').getAttribute('href');
                        linkDict[yearLinkNode + " " + linkName] = linkRef;
                    });
                    return linkDict;
                }, {yearLinkNode, link});

                // links = Object.assign({}, links, data);      // two ways to merge dictionaries: [https://stackoverflow.com/questions/43449788/how-do-i-merge-two-dictionaries-in-javascript/43449825]
                links = [links, data].reduce((function(total, dict){
                    Object.keys(dict).forEach(function(key){
                        total[key] = dict[key];
                    });
                    return total;
                }), links);

            }
        };
        fs.writeFile('websites.json', JSON.stringify(links, null, 2), (err) => (err)? console.log(err): console.log('saved'));
        // get idx files
        // const client = await context.newCDPSession(page);
        // await client.send('Page.setDownloadBehavior', {
        //     behavior: 'allow',
        //     downloadPath: './'
        // });
        // for(link in links){
        //     let idxLink = links[link];
        //     await page.goto(idxLink);
        //     let files = await page.$$('table tr a');
        //     console.log(files);
        //     for(file in files){
        //         console.log(file.innerText);
        //         console.log();
        //         if(file.innerText === 'crawler.idx'){
        //             await page.click(file);
        //             await page.waitForTimeout(1000);
        //         }
        //     }
        // }

        await browser.close();
    
    }
    catch(err){
        console.log(err);
    }    

})();