const path = require('path')

module.exports = {
  name: path.basename(process.cwd()),
  version: '0.1.0',
  type: 'module',
  author: 'Nik. Kyriakides <nicholaswmin>',
  license: 'MIT',
  repository: {
    type: 'git',
    url: `https://github.com/nicholaswmin/${path.basename(process.cwd())}`
  },
  bugs: {
    url: `https://github.com/nicholaswmin/${path.basename(process.cwd())}/issues`
  },
  exports: './src/index.js',
  imports: {
    '#*': './src/*'
  },
  scripts: {
    test: 'node --test'
  },
  engines: {
    node: '>=24.0.0'
  }
}
