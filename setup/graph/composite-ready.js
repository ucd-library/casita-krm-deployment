const fs = require('fs');
const path = require('path');

module.exports = {
  mesoscale : (uri, msg, config) => {
    // let pathname = path.parse(uri.pathname).dir;
    // pathname = path.join(config.fs.nfsRoot, pathname, '..');
  
    // let blocks = fs.readdirSync(pathname);
    // let completed = 0;
    // for( let blockDir of blocks ) {
    //   if( fs.existsSync(path.join(pathname, blockDir, 'image.png')) ) {
    //     completed++;
    //   }
    // }
  
    // return ( blocks.length === completed);
    return ( msg.data.ready.length === msg.data.required.length );
  },

  conus : (uri, msg, config) => {
    return ( 
      msg.data.ready.length === msg.data.required.length && 
      msg.data.ready.length >= 36 
    )
  },

  fulldisk : (usi, msg, config) => {
    return ( 
      msg.data.ready.length === msg.data.required.length && 
      msg.data.ready.length >= 229 
    )
  }
}

