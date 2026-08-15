/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        ink: '#0D0D0D',
        green: {
          DEFAULT: '#188C4A',
          deep: '#297349',
          muted: '#648C75',
          neon: '#0DF205',
        },
        canvas: '#FFFFFF',
        card: '#FAFAFA',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        display: ['Plus Jakarta Sans', 'Inter', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
