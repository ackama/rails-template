const configAckamaBase = require('eslint-config-ackama');
const configAckamaJest = require('eslint-config-ackama/jest');
const configAckamaReact = require('eslint-config-ackama/react');
const configAckamaTypeScript = require('eslint-config-ackama/typescript');
const pluginJestDOM = require('eslint-plugin-jest-dom');
const pluginTestingLibrary = require('eslint-plugin-testing-library');
const globals = require('globals');

/** @type {import('eslint').Linter.FlatConfig[]} */
const config = [
  { files: ['**/*.{js,jsx,cjs,mjs,ts,tsx,cts,mts}'] },
  { ignores: ['tmp/*'] },
  ...configAckamaBase,
  ...configAckamaReact,
  ...configAckamaTypeScript,
  { languageOptions: { parserOptions: { project: true } } },
  {
    files: ['config/webpack/*', 'babel.config.js', 'eslint.config.js'],
    languageOptions: {
      sourceType: 'script',
      globals: { ...globals.node }
    },
    rules: {
      '@typescript-eslint/prefer-nullish-coalescing': 'off',
      '@typescript-eslint/no-require-imports': 'off',
      '@typescript-eslint/no-var-requires': 'off'
    }
  },
  ...[
    pluginJestDOM.configs['flat/recommended'],
    pluginTestingLibrary.configs['flat/dom'],
    pluginTestingLibrary.configs['flat/react'],
    ...configAckamaJest,
    /** @type {import('eslint').Linter.FlatConfig} */ ({
      rules: { 'jest/prefer-expect-assertions': 'off' }
    })
  ].map(c => ({ ...c, files: ['app/frontend/test/**'] }))
];

module.exports = config;
