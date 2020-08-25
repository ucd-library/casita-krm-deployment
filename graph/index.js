const fs = require('fs');
const path = require('path');
const {URL} = require('url');

const IMAGE_SCALES = /^(mesoscale|conus|fulldisk|solar-imagery-euv-data)$/;

const WORKERS = {
  DEFAULT : 'default.worker',
  NODE_IMAGE_UTILS : 'node.image.worker'
}

module.exports = {
  name : 'casita',
  graph : {

    'file:///:scale/:date/:time/:band/:apid/cells/:cell/image.png' : {
      name : 'Merge and convert JP2 fragments',
      worker : WORKERS.NODE_IMAGE_UTILS,
      dependencies : [{
        subject : 'file:///:scale/:date/:time/:band/:apid/cells/:cell/fragments/:fragment/image_fragment.jp2',
        constraints : {
          scale : IMAGE_SCALES
        }
      }],
      options : {
        dependentCount : (subject, rootDir) => {
          let pathname = path.parse(new URL(subject).pathname).dir;
          pathname = path.join(rootDir, pathname, '..', '..', 'fragment-metadata.json');
          if( !fs.existsSync(pathname) ) return 9999;
          return JSON.parse(fs.readFileSync(pathname, 'utf-8')).fragmentsCount;
        }
      },
      command : (msg, opts) => `node-image-utils jp2-to-png ${opts.fs.nfsRoot}${opts.uri.pathname}`
    }
  }
}