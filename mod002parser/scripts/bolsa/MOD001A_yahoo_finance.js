//---  Programa en NODE.js que descarga datos de Yahoo Finance-------------------------------

console.log("\nDescarga YF: INICIO");

var yahooFinance = require('yahoo-finance');
var fs = require('fs');


var segundos_wait=10;
var periodicidad='d'  // 'd' (daily), 'w' (weekly), 'm' (monthly), 'v' (dividends only);
var pathDirOut="/home/carloslinux/Desktop/DATOS_BRUTO/bolsa/";


console.log("--PARAMETROS DE ENTRADA--")
var empresaParam = process.argv[2]; //Empresa (ticker en Yahoo Finance). Ej: TPZ.MC
var anio = process.argv[3]; //ANIO
var fechaDesdeNoIncluido = anio+"-01-01";
var fechaHastaInclusive = anio+"-12-31";
console.log("Empresa: "+empresaParam);
console.log("fechaDesdeNoIncluido: "+fechaDesdeNoIncluido);
console.log("fechaHastaInclusive: "+fechaHastaInclusive);


//############# FUNCIONES ###########################

function descargar(empresaObject){

  var empresa=empresaObject+'';
  if(empresa!=''){

    var pathOut=pathDirOut+"YF_"+anio+"_"+empresa;
    console.log("Cargando datos de empresa "+empresa+" desde Yahoo...");
    console.log("Fichero out: "+pathOut);
    var promiseEmpresa= yahooFinance.historical({
      symbol: empresa,
      from: fechaDesdeNoIncluido,
      to: fechaHastaInclusive,
      period: periodicidad
    }, function (err, quotes) {

    var salida=JSON.stringify(quotes);

    fs.writeFile(pathOut, salida, 'utf8', function(err) {
      if(err) {
          return console.log(err);
      }
    });

   });

  } //fin de IF

}


//##################### CODIGO PRINCIPAL #############

descargar(empresaParam);


console.log("Descarga YF: FIN");


