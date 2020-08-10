module.exports = {
  root: true,
  parserOptions: {
    ecmaVersion: 2019,
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true
    }
  },
  env: { browser: true, commonjs: true, node: true, es6: true },
  plugins: ['react', 'react-hooks', 'jsx-a11y', 'prettier', 'eslint-comments'],
  extends: [
    'ackama',
    'ackama/react',
    'plugin:eslint-comments/recommended',
    'plugin:prettier/recommended',
    'plugin:react/recommended',
    'plugin:jsx-a11y/strict',
    'prettier/react'
  ],
  ignorePatterns: ["tmp/"],
  settings: {
    react: { version: 'detect' }
  },
  rules: {
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': ['warn'],
    'react/button-has-type': 'warn',
    'react/default-props-match-prop-types': 'warn',
    'react/no-access-state-in-setstate': 'warn',
    'react/no-direct-mutation-state': 'warn',
    'react/no-this-in-sfc': 'warn',
    'react/no-will-update-set-state': 'warn',
    'react/no-unused-state': 'warn',
    'react/prefer-stateless-function': 'warn',
    'react/self-closing-comp': 'warn',
    'react/void-dom-elements-no-children': 'warn',
    'react/jsx-boolean-value': 'warn',
    'react/jsx-closing-bracket-location': ['warn', 'line-aligned'],
    'react/jsx-closing-tag-location': 'warn',
    'react/jsx-curly-spacing': 'warn',
    'react/jsx-equals-spacing': 'warn',
    'react/jsx-filename-extension': ['warn', { extensions: ['.tsx', '.jsx'] }],
    'react/jsx-first-prop-new-line': 'warn',
    'react/jsx-handler-names': 'error',
    'react/jsx-no-bind': 'error',
    'react/jsx-fragments': 'warn',
    'react/jsx-tag-spacing': 'error',
    'react/display-name': 'off',
    'eslint-comments/no-unused-disable': 'error',
    'no-var': 'error',
    'no-else-return': 'error',
    'no-return-await': 'error',
    'no-throw-literal': 'error',
    'no-sparse-arrays': 'error',
    'no-param-reassign': 'error',
    'no-ex-assign': 'error',
    'no-underscore-dangle': 'off',
    'no-useless-constructor': 'error',
    'no-with': 'error',
    'no-plusplus': ['error', { allowForLoopAfterthoughts: true }],
    'no-nested-ternary': 'error',
    'no-shadow': 'warn',
    'no-shadow-restricted-names': 'error',
    'no-this-before-super': 'error',
    'prefer-arrow-callback': 'warn',
    'newline-before-return': 'error',
    'curly': 'error',
    'eqeqeq': 'error',
    'guard-for-in': 'error',
    'default-case': 'error',
    'radix': 'error',
    'dot-notation': 'error',
    'consistent-this': ['error', 'self'],
    'yoda': 'error',
    'new-cap': ['error', { capIsNewExceptions: ['Callsite'] }],
    'spaced-comment': [
      'warn',
      'always',
      {
        markers: ['=', '#region'],
        exceptions: ['#endregion']
      }
    ],
    'camelcase': 'error'
  }
};
