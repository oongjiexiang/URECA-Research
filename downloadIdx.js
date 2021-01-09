const {chromium} = require('playwright');
const ObjectsToCsv = require('objects-to-csv');
const fs = require('fs');

const homePage = 'https://www.sec.gov/Archives/edgar/full-index/';

async function loadLinks(links){
    let loadFile = new Promise(function(resolve, reject){
        fs.readFile('./websites.json', function(err, data){
            links = JSON.parse(data);
            resolve(links);
        });
    });
    return await loadFile;
}

(async () => {
    try{
        const browser = await chromium.launch({headless: false});
        const context = await browser.newContext();
        const page = await context.newPage();

        var links = {};
        links = await loadLinks(links);
        console.log(links);


        // get idx files
        const client = await context.newCDPSession(page);
        await client.send('Page.setDownloadBehavior', {
            behavior: 'allow',
            downloadPath: './'
        });
        for(link in links){
            let idxLink = links[link];
            await page.goto(idxLink);
            let files = await page.$$('table tr a');
            for(file in files){
                let clickableLink = files[file];
                if(await clickableLink.getAttribute('href') === 'crawler.idx'){
                    await page.click(clickableLink.getAttribute('href'));
                    await page.waitForTimeout(1000);
                }
            }
            // let files = await page.evaluate(() => {
            //     return document.querySelectorAll('table tr');
            // });
            // for(file in files){
            //     console.log(files[file].innerHTML);
            // }
            // console.log(files[1]);
            // for(file in files){
            //     // console.log(file.innerText);
            //     // console.log();
            //     if(file.innerText === 'crawler.idx'){
            //         console.log('attempting to click');
            //         await page.click(file);
            //         await page.waitForTimeout(1000);
            //     }
            // }
        }

        await browser.close();
    
    }
    catch(err){
        console.log(err);
    }    

})();