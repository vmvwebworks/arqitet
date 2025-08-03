module.exports = {
  content: [
    "./app/views/**/*.{html,erb,slim}",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
  ],
  theme: {
    extend: {
      colors: {
        terracota: '#D9825B',
        arena: '#F6EFE7',
        oliva: '#A79D8E',
        ocre: '#E5C49B',
        granate: '#8B4C4A',
      },
    },
  },
  plugins: [],
}