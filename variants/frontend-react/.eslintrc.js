'use strict';

const config = {
  root: true,
  env: { commonjs: true, node: true, browser: true },
  extends: ['ackama', 'ackama/react'],
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
    },
    {
      files: ['app/frontend/test/**'],
      extends: [
        'ackama/jest',
        'plugin:jest-dom/recommended',
        'plugin:testing-library/dom',
        'plugin:testing-library/react'
      ],
      plugins: ['testing-library', 'jest-dom'],
      rules: {
        'jest/prefer-expect-assertions': 'off'
      }
    }
  ]
};

module.exports = config;
