var fs = require('fs')
  , spawn = require('child_process').spawn
  , forever = require('forever')
  , utile = require('forever/node_modules/utile');

module.exports = function (command, options) {
  options         = options || {};
  options.uid     = options.uid || utile.randomString(4).replace(/^\-/, '_');
  options.logFile = forever.logFilePath(options.logFile || options.uid + '.log');
  options.pidFile = forever.pidFilePath(options.pidFile || options.uid + '.pid');
  options.full_command = command;

  var monitor, outFD, errFD, workerPath;

  outFD = fs.openSync(options.logFile, 'a');
  errFD = fs.openSync(options.logFile, 'a');
  monitorPath = __filename;
  
  monitor = spawn('node', [monitorPath], {
    stdio: ['ipc', outFD, errFD],
    detached: true
  });

  monitor.on('exit', function (code) {
    console.error('Monitor died unexpectedly with exit code %d', code);
  });

  monitor.send(JSON.stringify(options));
  monitor.unref();
};

if (process.send) {
  // Child
  var started = false;
  
  function writePid(file, pid) {
    fs.writeFileSync(file, pid, 'utf8');
  }
  
  function start(opts) {
    var cmd_parts = opts.full_command.split(/ +/)
      , monitor = new forever.Monitor(cmd_parts, opts);
    
    monitor.command = cmd_parts[0];
    monitor.args = cmd_parts.slice(1);
    
    forever.logEvents(monitor);
    monitor.start();
    
    monitor.on('start', function() {
      forever.startServer(monitor);
      process.disconnect();
      writePid(opts.pidFile, monitor.child.pid);
    });
    
    monitor.on('restart', function() {
      writePid(options.pidFile, monitor.child.pid);
    });
    
    function clean_up() {
      try {
        fs.unlinkSync(opts.pidFile);
      } catch(e) {
        
      }
    }
    
    monitor.on('stop', clean_up);
    monitor.on('exit', clean_up);
  }
  
  process.on('message', function(data) {
    var opts = JSON.parse(data.toString());
    if (!started) {
      started = true;
      start(opts);
    }
  });
}
