import type { Config } from "tailwindcss";
export default { content:["./app/**/*.{ts,tsx}","./components/**/*.{ts,tsx}"], theme:{extend:{colors:{ink:"#10201e",paper:"#f7f7f2",mint:"#c8f1df",forest:"#175747",coral:"#fa7560"},boxShadow:{soft:"0 18px 50px rgba(16,32,30,.10)"}}}, plugins:[] } satisfies Config;
