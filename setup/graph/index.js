const fs = require('fs');
const path = require('path');
const {URL} = require('url');
const compositeReady = require('./composite-ready');

const IMAGE_SCALES = /^(mesoscale|conus|fulldisk|solar-imagery-euv-data)$/;
const GENERIC_PAYLOAD_APIDS = /^(301|302)$/;

const WORKERS = {
  DEFAULT : 'default.worker',
  NODE_IMAGE_UTILS : 'node.image.worker',
  RING_BUFFER : 'ring.buffer.worker',
  NODE_STATUS : 'node.status.worker',
  GENERIC : 'generic.payload.worker',
  EXTERNAL_TOPICS : 'external.topics.worker'
}

module.exports = {

    'file:///west/{scale}/{date}/{hour}/{minsec}/{band}/{apid}/blocks/{block}/image.png' : {
      name : 'Merge and convert JP2 fragments',
      worker : WORKERS.NODE_IMAGE_UTILS,
      dependencies : [{
        subject : 'file:///west/{scale}/{date}/{hour}/{minsec}/{band}/{apid}/blocks/{block}/fragments/{fragment}/image-fragment.jp2',
        constraints : {
          scale : IMAGE_SCALES
        }
      }],
      options : {
        ready : (uri, msg, config) => {
          let pathname = path.parse(uri.pathname).dir;
          pathname = path.join(config.fs.nfsRoot, pathname, '..', '..', 'fragment-metadata.json');
          if( !fs.existsSync(pathname) ) return false;

          let count = JSON.parse(fs.readFileSync(pathname, 'utf-8')).fragmentsCount;
          return ( msg.data.ready.length >= count);
        }
      },
      command : (uri, msg, config) => `node-image-utils jp2-to-png ${config.fs.nfsRoot}${uri.pathname}`
    },

    // 'file:///west/fulldisk/{date}/{hour}/{minsec}/{band}/{apid}/image.png' : {
    //   name : 'Create fulldisk composite images',
    //   worker : WORKERS.NODE_IMAGE_UTILS,
    //   dependencies : [{
    //     subject : 'file:///west/fulldisk/{date}/{hour}/{minsec}/{band}/{apid}/blocks/{block}/image.png',
    //   }],
    //   options : {
    //     ready : compositeReady.fulldisk,
    //     timeout : 20 * 60 * 1000
    //   },
    //   command : (uri, msg, config) => `node-image-utils composite ${config.fs.nfsRoot}${uri.pathname}`
    // },

    'file:///west/conus/{date}/{hour}/{minsec}/{band}/{apid}/image.png' : {
      name : 'Create conus composite images',
      worker : WORKERS.NODE_IMAGE_UTILS,
      dependencies : [{
        subject : 'file:///west/conus/{date}/{hour}/{minsec}/{band}/{apid}/blocks/{block}/image.png',
      }],
      options : {
        ready : compositeReady.conus,
        timeout : 10 * 60 * 1000,
        readyDelay : 2 * 1000
      },
       command : (uri, msg, config) => `node-image-utils composite ${config.fs.nfsRoot}${uri.pathname}`
    },

    'file:///west/mesoscale/{date}/{hour}/{minsec}/{band}/{apid}/image.png' : {
      name : 'Create mesoscale composite images',
      worker : WORKERS.NODE_IMAGE_UTILS,
      dependencies : [{
        subject : 'file:///west/mesoscale/{date}/{hour}/{minsec}/{band}/{apid}/blocks/{block}/image.png',
      }],
      options : {
        ready : compositeReady.mesoscale
      },
      command : (uri, msg, config) => `node-image-utils composite ${config.fs.nfsRoot}${uri.pathname}`
    },

    'file:///west/{scale}/{date}/{hour}/{minsec}/{band}/{apid}/web-scaled.png' : {
      name : 'Create web scale composite images',
      worker : WORKERS.NODE_IMAGE_UTILS,
      dependencies : [{
        subject : 'file:///west/{scale}/{date}/{hour}/{minsec}/{band}/{apid}/image.png',
      }],
      command : (uri, msg, config) => `node-image-utils scale ${config.fs.nfsRoot}${uri.pathname} ${msg.data.args.band}`
    },

    'file:///west/{scale}/{date}/{hour}/{minsec}/{band}/{apid}/blocks/{block}/web-scaled.png' : {
      name : 'Create web scale composite images',
      worker : WORKERS.NODE_IMAGE_UTILS,
      dependencies : [{
        subject : 'file:///west/{scale}/{date}/{hour}/{minsec}/{band}/{apid}/blocks/{block}/image.png',
      }],
      command : (uri, msg, config) => `node-image-utils scale ${config.fs.nfsRoot}${uri.pathname} ${msg.data.args.band}`
    },

    'file:///west/{scale}/{date}/{hour}/{minsec}/{ms}/{apid}/payload.json' : {
      name : 'Generic payload parser',
      worker : WORKERS.GENERIC,
      dependencies : [{
        subject : 'file:///west/{scale}/{date}/{hour}/{minsec}/{ms}/{apid}/payload.bin',
        constraints : {
          apid : GENERIC_PAYLOAD_APIDS
        }
      }],
      command : (uri, msg, config) => `node /command ${config.fs.nfsRoot}${new URL(msg.data.ready[0]).pathname}`
    },

    'file:///west/{scale}/{date}/{hour}/{minsec}/{apid}/payload.json' : {
      name : 'Generic payload parser',
      worker : WORKERS.GENERIC,
      dependencies : [{
        subject : 'file:///west/{scale}/{date}/{hour}/{minsec}/{apid}/payload.bin',
        constraints : {
          apid : GENERIC_PAYLOAD_APIDS
        }
      }],
      command : (uri, msg, config) => `node /command ${config.fs.nfsRoot}${new URL(msg.data.ready[0]).pathname}`
    },

    'file:///west/{scale}/{date}/{hour}/{minsec}/summary/301/stats.json' : {
      name : 'Generic payload parser',
      worker : WORKERS.GENERIC,
      dependencies : [{
        subject : 'file:///west/{scale}/{date}/{hour}/{minsec}/{ms}/301/payload.json'
      }],
      options : {
        ready : (uri, msg, config) => {
          let pathname = path.parse(uri.pathname).dir;
          pathname = path.join(config.fs.nfsRoot, pathname, '..', '..');
          let count = fs.readdirSync(pathname).length;

          return ( msg.data.ready.length >= count );
        }
      },
      command : (uri, msg, config) => `node /command ${config.fs.nfsRoot}${uri.pathname}`
    },

    'http://custom.googleapis.com/grb/time_to_disk/{scale}/{date}/{hour}/{minsec}/{bandms}/{apid}' : {
      name : 'GRB Stream Status',
      worker : WORKERS.NODE_STATUS,
      dependencies : [{
        subject : 'file:///west/{scale}/{date}/{hour}/{minsec}/{bandms}/{apid}/blocks/{block}/fragment-metadata.json',
      },{
        subject : 'file:///west/{scale}/{date}/{hour}/{minsec}/{bandms}/{apid}/metadata.json',
      }],
      command : (uri, msg, config) => ({
        type : 'time_to_disk',
        file : `${new URL(msg.data.ready[0]).pathname}`
      })
    },

    'http://custom.googleapis.com/krm/comp_png_gen_time/{scale}/{date}/{hour}/{minsec}/{band}/{apid}/{block}' : {
      name : 'GRB Stream Status',
      worker : WORKERS.NODE_STATUS,
      dependencies : [{
        subject : 'file:///west/{scale}/{date}/{hour}/{minsec}/{band}/{apid}/blocks/{block}/image.png',
      }],
      command : (uri, msg, config) => ({
        type : 'comp_png_gen_time',
        file : `${new URL(msg.data.ready[0]).pathname}`
      })
    },

    'http://casita.library.ucdavis.edu/ring-buffer/{date}/{hour}/{minsec}/{band}/{apid}/blocks/{block}/image.png' : {
      name : 'Add image to postgis',
      worker : WORKERS.RING_BUFFER,
      dependencies : [{
        subject : 'file:///west/{scale}/{date}/{hour}/{minsec}/{band}/{apid}/blocks/{block}/image.png',
        constraints : {
          apid : /^(b6|96)$/,
          block : /^(3164-657|3164-910|1666-213|1666-465|2083-465)$/
        }
      }]
    },
    'http://casita.library.ucdavis.edu/open-kafka-lightning/{product}/{date}/{hour}/{minsec}/{ms}/{apid}/payload.json' : {
      name : 'export lightning information to kafka topic',
      worker : WORKERS.EXTERNAL_TOPICS,
      dependencies : [{
        subject : 'file:///west/{product}/{date}/{hour}/{minsec}/{ms}/{apid}/payload.json',
        constraints : {
          // product : /^(lightning-detection-event-data|lightning-detection-flash-data|lightning-detection-group-data|lightning-detection-metadata)$/,
          apid : /^(301|302|303|300)$/,
          // file : /^(payload.json|payload.bin)$/
        }
      }]
    }
}
