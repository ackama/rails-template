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

// todo: even though shakapacker ships with its own types, it currently types
//  itself as "any" which will hopefully change in a future version
declare module 'shakapacker' {
  import { Configuration } from 'webpack';

  export function generateWebpackConfig(
    extraConfig?: Configuration
  ): Configuration;
  export * from 'webpack-merge';
}
