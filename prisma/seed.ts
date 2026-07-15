import { PrismaClient, Role } from "@prisma/client";
const prisma=new PrismaClient();
const names=["Shahul","Shefeer","Sanu","Nuhman","Rafsan","Ajmal","Rinshad","Adith","Diljith","Shazin"];
async function main(){
 const members=await Promise.all(names.map(name=>prisma.member.upsert({where:{id:`seed-${name.toLowerCase()}`},update:{},create:{id:`seed-${name.toLowerCase()}`,name,active:true}})));
 await prisma.user.upsert({where:{email:"shahul@rentflow.local"},update:{},create:{email:"shahul@rentflow.local",authId:"seed-admin",role:Role.ADMIN}});
 const month=await prisma.month.upsert({where:{startsOn:new Date("2026-07-01T00:00:00.000Z")},update:{},create:{startsOn:new Date("2026-07-01T00:00:00.000Z"),endsOn:new Date("2026-07-31T23:59:59.000Z"),rent:40000}});
 await Promise.all(members.map((member,index)=>prisma.rentPayment.upsert({where:{monthId_memberId:{monthId:month.id,memberId:member.id}},update:{},create:{monthId:month.id,memberId:member.id,amountDue:4000,amountPaid:index<5?4000:index===5?2500:0,status:index<5?"PAID":index===5?"PARTIAL":"PENDING",method:index<6?"UPI":null}})));
}
main().finally(()=>prisma.$disconnect());
