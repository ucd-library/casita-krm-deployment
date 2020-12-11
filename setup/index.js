module.exports = {
  name : 'casita',
  graph : require('./graph'),
  eventShortcuts : {
    'fulldisk-band2' : /^file:\/\/\/west\/fulldisk\/\d{4}-\d{2}-\d{2}\/\d{2}\/\d{2}-\d{2}\/2\/91\/blocks\/\d+-\d+\/image\.png$/
  },
  services : [
    {hostname : 'ws-service', route : 'ws'},
    {hostname : 'stream-status-service', route : 'status'},
    {hostname : 'h2-service', route : 'h2'}
  ]
}