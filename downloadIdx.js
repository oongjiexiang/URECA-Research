const ObjectsToCsv = require('objects-to-csv');
const fs = require('fs');
var exec = require('child_process').exec, child;

const homePage = 'https://www.sec.gov/Archives/edgar/full-index/';

function CsvToObjects(str, delimiter){
    const title = str.slice(0, str.indexOf('\n')).split(delimiter);
    const rows = str.slice(str.indexOf('\n') + 1).split('\n');
    return rows.map((row) => {
        var values = row.split(delimiter);
        return title.reduce((object, current, i)=>{
            object[current] = values[i];
        }, {});
    });
}

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
        var links = {};
        links = await loadLinks(links);
        for(var link in links){
            var command = 'sh extract.sh ' + links[link];
            console.log(command)
            const extract = exec(command);
            extract.stdout.on('data', (data) => {
                console.log(data);
            });
            extract.stderr.on('data', (data) => {
                console.error(data);
            });
        }
        // var csvData;
        // fs.readFile('trading_doc_db.csv', (err, data)=>{
        //     if(err) console.log(err);
        //     else{
        //         csvData = data;
        //     }
        // })
        // fs.writeFile('trading_doc_db.json', CsvToObjects(csvData, ':'), (err)=>(err)? console.log(err): console.log("operation successful"))
    }
    catch(err){
        console.log(err);
    }    

})();

// converting csv to json function [https://medium.com/@sanderdebr/converting-csv-to-a-2d-array-of-objects-94d43c56b12d]