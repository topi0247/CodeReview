const preset = require("franken-ui/shadcn-ui/preset");
const variables = require("franken-ui/shadcn-ui/variables");
const ui = require("franken-ui");
const hooks = require("franken-ui/shadcn-ui/hooks");

const shadcn = hooks({
  theme: "zinc",
});

module.exports = {
  content: [
    './app/views/**/*.html.slim',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  presets: [preset],
  safelist: [
    {
      pattern: /^uk-/,
    },
  ],
  theme: {
    extend: {},
  },
  plugins: [
    variables({
      theme: "slate",
    }),
    ui({
      components: {
        accordion: {
          hooks: shadcn.accordion,
        },
        button: {
          hooks: {}
        },
        'form-range': {
          hooks: {}
        },
        form: {
          hooks: {},
          media: true
        },
      },
    }),
  ],
};