'use strict';

const defaultConfigFunc = require('shakapacker/package/babel/preset.js');

/** @type {import('@babel/core').ConfigFunction} */
const config = api => {
  const resultConfig = defaultConfigFunc(api);

  resultConfig.plugins = [
    ...resultConfig.plugins,
    ['@babel/plugin-transform-typescript', { allowDeclareFields: true }]
  ];

  return resultConfig;
};

module.exports = config;
