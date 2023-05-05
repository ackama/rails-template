declare module 'shakapacker' {
  import { Configuration } from 'webpack';

  export { merge } from 'webpack-merge';
  export const webpackConfig: Configuration;
}

declare module 'shakapacker/package/babel/preset.js' {
  import { ConfigAPI, PluginItem, TransformOptions } from '@babel/core';

  interface RequiredTransformOptions {
    plugins: PluginItem[];
    presets: PluginItem[];
  }

  const defaultConfigFunc: (
    api: ConfigAPI
  ) => TransformOptions & RequiredTransformOptions;

  export = defaultConfigFunc;
}

declare module '*.svg' {
  const content: string;
  export default content;
}

declare module '*.png' {
  const content: string;
  export default content;
}

declare module '*.jpg' {
  const content: string;
  export default content;
}
