'use strict';

const config = {
  root: true,
  env: {
    commonjs: true,
    node: true,
    browser: true
  },
  extends: [
    'ackama',
    'ackama/react',
    'plugin:testing-library/recommended',
    'plugin:testing-library/react'
  ],
  plugins: ['testing-library', 'jest-dom', 'jest'],
  ignorePatterns: ['tmp/'],
  parserOptions: { sourceType: 'module' },
  overrides: [
    {
      files: [
        'config/webpack/*',
        'postcss.config.js',
        'babel.config.js',
        '.eslintrc.js'
      ],
      parserOptions: { sourceType: 'script' }
    }
  ],
  rules: {}
};

module.exports = config;
