'use strict';

const config = {
  root: true,
  env: { commonjs: true },
  extends: [
    'ackama',
    'ackama/react'
  ],
  ignorePatterns: ["tmp/"],
  rules: {}
};

module.exports = config;