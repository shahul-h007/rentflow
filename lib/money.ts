export const INR=(amount:number)=>new Intl.NumberFormat("en-IN",{style:"currency",currency:"INR",maximumFractionDigits:0}).format(amount);
export const splitEqually=(amount:number,memberIds:string[])=>memberIds.map((id,index)=>({memberId:id,amount:Math.floor(amount/memberIds.length)+(index<amount%memberIds.length?1:0)}));
