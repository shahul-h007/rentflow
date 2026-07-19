import { PrismaClient, Role } from "@prisma/client";
const prisma=new PrismaClient();
const names=["Shahul","Shefeer","Sanu","Nuhman","Rafsan","Ajmal","Rinshad","Adith","Diljith","Shazin"];
async function main() {
  console.log("Database seeded (mock data removed for production)");
}
main().finally(()=>prisma.$disconnect());
