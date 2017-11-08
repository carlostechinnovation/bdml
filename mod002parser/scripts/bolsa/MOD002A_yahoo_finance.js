//---  Programa en NODE.js que PROCESA JSON de Yahoo Finance hacia CSVs-------------------------------

var fs = require('fs');

//fully read file and parse some data out of it
'use strict';

var filename = process.argv[2];

var text = fs.readFileSync(filename).toString();
var objetoLeido1=text.replace(/^\[ *'|' *\]$/g,'');
var objetoLeido2 = JSON.parse(objetoLeido1);
//console.log("2->"+objetoLeido2);
//var objetoLeido3 = JSON.stringify(objetoLeido2);
//console.log("3->"+objetoLeido3);


for (var i=0; i<objetoLeido2.length; i++){
    x=objetoLeido2[i];

    var fields = [
    x.date,//0
    x.open,//1
    x.high,//2
    x.low,//3
    x.close,//4
    x.adjClose,//5
    x.volume,//6
    x.symbol//7
    ];

    console.log(fields[7]+"|"+fields[0].substring(0,10).replace("-","").replace("-","")+"|"+fields[1]+"|"+fields[2]+"|"+fields[3]+"|"+fields[4]+"|"+fields[6]);

}


