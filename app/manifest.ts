import type { MetadataRoute } from "next";
export default function manifest():MetadataRoute.Manifest{return {name:"RentFlow",short_name:"RentFlow",description:"Smart House Rent & Expense Management",start_url:"/",display:"standalone",background_color:"#f7f7f2",theme_color:"#175747",icons:[{src:"/icon.svg",sizes:"any",type:"image/svg+xml"}]}}
