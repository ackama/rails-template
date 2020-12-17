/* eslint-disable import/order */

declare module '@rails/webpacker' {
  import { Configuration, WebpackPluginInstance } from 'webpack';

  interface Plugins {
    prepend(name: string, plugin: WebpackPluginInstance): void;
  }

  interface Environment {
    plugins: Plugins;

    toWebpackConfig(): Configuration;
  }

  export const environment: Environment;
}

declare module 'react_ujs' {
  import RequireContext = __WebpackModuleApi.RequireContext;

  interface ReactRailsUJS {
    useContext(context: RequireContext): void;
  }

  const ReactRailsUJS: ReactRailsUJS;

  export default ReactRailsUJS;
}

declare module '@rails/actioncable' {
  import ActionCable from 'actioncable';

  export = ActionCable;
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
