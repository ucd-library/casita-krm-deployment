const fs = require('fs');
const path = require('path');
const {URL} = require('url');

const IMAGE_SCALES = /^(mesoscale|conus|fulldisk|solar-imagery-euv-data)$/;

const WORKERS = {
  DEFAULT : 'default.worker',
  NODE_IMAGE_UTILS : 'node.image.worker',
  NODE_STATUS : 'node.status.worker'
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
      command : (msg, opts) => `node-image-utils jp2-to-png ${opts.fs.nfsRoot}${opts.uri.pathname} --rm-fragments`
    },

    // 'file:///fulldisk/:date/:time/:band/:apid/image.png' : {
    //   name : 'Create fulldisk composite images',
    //   worker : WORKERS.NODE_IMAGE_UTILS,
    //   dependencies : [{
    //     subject : 'file:///fulldisk/:date/:time/:band/:apid/cells/:cell/image.png',
    //   }],
    //   options : {
    //     dependentCount : 232,
    //     timeout : 20 * 60 * 1000
    //   },
    //   command : (msg, opts) => `node-image-utils composite ${opts.fs.nfsRoot}${opts.uri.pathname}`
    // },

    // 'file:///conus/:date/:time/:band/:apid/image.png' : {
    //   name : 'Create conus composite images',
    //   worker : WORKERS.NODE_IMAGE_UTILS,
    //   dependencies : [{
    //     subject : 'file:///conus/:date/:time/:band/:apid/cells/:cell/image.png',
    //   }],
    //   options : {
    //     dependentCount : 229,
    //     delay : 500,
    //     timeout : 10 * 60 * 1000
    //   },
    //   command : (msg, opts) => `node-image-utils composite ${opts.fs.nfsRoot}${opts.uri.pathname}`
    // },

    // 'file:///mesoscale/:date/:time/:band/:apid/image.png' : {
    //   name : 'Create mesoscale composite images',
    //   worker : WORKERS.NODE_IMAGE_UTILS,
    //   dependencies : [{
    //     subject : 'file:///mesoscale/:date/:time/:band/:apid/cells/:cell/image.png',
    //   }],
    //   options : {
    //     dependentCount : 4,
    //     delay : 500
    //   },
    //   command : (msg, opts) => `node-image-utils composite ${opts.fs.nfsRoot}${opts.uri.pathname}`
    // },

    'http://casita.library.ucdavis.edu/stream-status/:scale/:date/:time/:cell/:band/:apid' : {
      name : 'GRB Stream Status',
      worker : WORKERS.NODE_STATUS,
      dependencies : [{
        subject : 'file:///:scale/:date/:time/:band/:apid/cells/:cell/fragment-metadata.json',
      },{
        subject : 'file:///:scale/:date/:time/:apid/metadata.json',
      }],
      command : (msg, opts) => `stream-status ${opts.fs.nfsRoot} ${new URL(msg.data.ready[0]).pathname}`,
    }
  }
}