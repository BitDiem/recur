const LIMIT = 1*1024 ;

function sizes (name) {
var abi = artifacts.require(name) ;
var size = (abi.bytecode.length / 2) - 1 ;
var deployedSize = (abi.deployedBytecode.length / 2) - 1 ;
return {name, size, deployedSize} ;
}

function fmt(obj) {
return `${ obj.name } ${ obj.size } ${ obj.deployedSize }` ;
}

var l = fs.readdirSync("build/contracts") ;
l.forEach(function (f) {
var name = f.replace(/.json/, '') ;
var sz = sizes(name) ;
if (sz.size >= LIMIT || sz.deployedSize >= LIMIT) {
    console.log(fmt(sz)) ;
}
}) ;