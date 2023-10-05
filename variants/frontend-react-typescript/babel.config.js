'use strict';

const defaultConfigFunc = require('shakapacker/package/babel/preset.js');

/**
 * Guards that `value` is not `false`
 *
 * @param {T | false} value
 *
 * @return {value is T}
 *
 * @template T
 */
const notFalseGuard = value => value !== false;

/** @type {import('@babel/core').ConfigFunction} */
const config = api => {
  const resultConfig = defaultConfigFunc(api);
  const isDevelopmentEnv = api.env('development');
  const isProductionEnv = api.env('production');
  const isTestEnv = api.env('test');

  const changesOnDefault = {
    presets: [
      [
        '@babel/preset-react',
        {
          development: isDevelopmentEnv || isTestEnv,
          useBuiltIns: true
        }
      ]
    ].filter(notFalseGuard),
    plugins: [
      ['@babel/plugin-transform-typescript', { allowDeclareFields: true }],
      isProductionEnv && [
        'babel-plugin-transform-react-remove-prop-types',
        {
          removeImport: true
        }
      ]
    ].filter(notFalseGuard)
  };

  resultConfig.presets = [...resultConfig.presets, ...changesOnDefault.presets];
  resultConfig.plugins = [...resultConfig.plugins, ...changesOnDefault.plugins];

  return resultConfig;
};

module.exports = config;
