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
  ],
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
      files: ['app/frontend/tests/**'],
      extends: ['ackama/jest', 'ackama/jest-formatting', 'plugin:testing-library/recommended',
        'plugin:testing-library/react'
      ],
      plugins: ['testing-library', 'jest-dom', 'jest'],
      rules: {
        'jest/prefer-expect-assertions': 'off',
      }
    },
  ],
  rules: {}
};

module.exports = config;
