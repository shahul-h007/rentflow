import { PrismaClient, Role } from "@prisma/client";
const prisma=new PrismaClient();
const names=["Shahul","Shefeer","Sanu","Nuhman","Rafsan","Ajmal","Rinshad","Adith","Diljith","Shazin"];
async function main(){
 // 1. Create or update the House
 const house = await prisma.house.upsert({
   where: { id: "seed-house" },
   update: {
     name: "Green Villa",
     rent: 30000,
     dueDate: 5,
     currency: "INR",
     ownerName: "Shahul",
     upiId: "shahul@oksbi",
   },
   create: {
     id: "seed-house",
     name: "Green Villa",
     rent: 30000,
     dueDate: 5,
     currency: "INR",
     ownerName: "Shahul",
     upiId: "shahul@oksbi",
   }
 });

 // 2. Create or update Members (linked to the House)
 const members=await Promise.all(names.map(name=>prisma.member.upsert({
   where:{id:`seed-${name.toLowerCase()}`},
   update:{
     houseId: house.id
   },
   create:{
     id:`seed-${name.toLowerCase()}`,
     name,
     active:true,
     houseId: house.id
   }
 })));

 // 3. Admin User
 await prisma.user.upsert({
   where:{email:"shahul@rentflow.local"},
   update:{},
   create:{
     email:"shahul@rentflow.local",
     authId:"seed-admin",
     role:Role.ADMIN
   }
 });

 // 4. Create or update current active month (linked to the House)
 const month=await prisma.month.upsert({
   where:{startsOn:new Date("2026-07-01T00:00:00.000Z")},
   update:{
     rent: 30000,
     houseId: house.id,
   },
   create:{
     startsOn:new Date("2026-07-01T00:00:00.000Z"),
     endsOn:new Date("2026-07-31T23:59:59.000Z"),
     rent:30000,
     houseId: house.id,
   }
 });

 // 5. Create or update rent payment records (linked to the Month)
 await Promise.all(members.map((member,index)=>prisma.rentPayment.upsert({
   where:{monthId_memberId:{monthId:month.id,memberId:member.id}},
   update:{
     amountDue: 3000,
     amountPaid: index < 5 ? 3000 : index === 5 ? 1500 : 0,
     status: index < 5 ? "PAID" : index === 5 ? "PARTIAL" : "PENDING",
     method: index < 6 ? "UPI" : null
   },
   create:{
     monthId:month.id,
     memberId:member.id,
     amountDue:3000,
     amountPaid:index<5?3000:index===5?1500:0,
     status:index<5?"PAID":index===5?"PARTIAL":"PENDING",
     method:index<6?"UPI":null
   }
 })));
}
main().finally(()=>prisma.$disconnect());

