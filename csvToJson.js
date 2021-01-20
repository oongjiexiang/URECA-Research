const ObjectsToCsv = require('objects-to-csv');
const fs = require('fs');

function CsvToObjects(str, delimiter){
    const title = str.slice(0, str.indexOf('\n')).split(delimiter);
    const rows = str.slice(str.indexOf('\n') + 1).split('\n');
    return rows.map((row) => {
        var values = row.split(delimiter);
        return title.reduce((object, current, i)=> (object[current] = values[i], object), {});
    });
}

(async () => {
    try{
        var csvData = fs.readFile('data.csv', 'utf-8', (err, data) => {
            if (err)
                console.log(err);
            else {
                fs.writeFile('data.json', JSON.stringify(CsvToObjects(data, '|'), null, 2), (err)=>(err)? console.log(err): console.log("operation successful"))
            }
        })
    }
    catch(err){
        console.log(err);
    }
    
})();


