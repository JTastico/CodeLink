// eslint.config.cjs
const js = require('@eslint/js');
const pluginNode = require('eslint-plugin-n');

/** @type {import("eslint").Linter.FlatConfig[]} */
module.exports = [
  js.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'commonjs',
      globals: {
        require: 'readonly',
        module: 'readonly',
        exports: 'readonly',
        console: 'readonly',
      },
    },
    plugins: {
      n: pluginNode,
    },
    rules: {
      indent: ['error', 2],
      'max-len': ['warn', { code: 100 }],
      'comma-dangle': ['error', 'always-multiline'],
      'no-unused-vars': ['warn'],
    },
  },
];
