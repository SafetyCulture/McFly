var path = require('path');

if(process.env.COVERAGE) {
    require('coffee-coverage').register({
        basePath: path.join(__dirname, "../lib"),
        exclude: ['/test', '/node_modules', '/conversions', '/.git'],
        initAll: true
    });
}