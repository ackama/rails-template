'use strict';

const defaultConfigFunc = require('shakapacker/package/babel/preset.js');

/** @type {import('@babel/core').ConfigFunction} */
const config = api => {
  const resultConfig = defaultConfigFunc(api);
  const isDevelopmentEnv = api.env('development');
  const isProductionEnv = api.env('production');
  const isTestEnv = api.env('test');

  resultConfig.presets.push([
    '@babel/preset-react',
    {
      development: isDevelopmentEnv || isTestEnv,
      useBuiltIns: true
    }
  ]);

  resultConfig.plugins.push([
    '@babel/plugin-transform-typescript',
    { allowDeclareFields: true }
  ]);

  if (isProductionEnv) {
    resultConfig.plugins.push([
      'babel-plugin-transform-react-remove-prop-types',
      { removeImport: true }
    ]);
  }

  return resultConfig;
};

module.exports = config;
