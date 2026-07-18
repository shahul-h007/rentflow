const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

async function main() {
  console.log("--- HOUSES ---");
  const houses = await prisma.house.findMany();
  console.log(JSON.stringify(houses, null, 2));

  console.log("--- MONTHS ---");
  const months = await prisma.month.findMany();
  console.log(JSON.stringify(months, null, 2));

  console.log("--- USERS ---");
  const users = await prisma.user.findMany();
  console.log(JSON.stringify(users, null, 2));

  console.log("--- MEMBERS ---");
  const members = await prisma.member.findMany();
  console.log(JSON.stringify(members, null, 2));
}

main()
  .catch((e) => console.error(e))
  .finally(() => prisma.$disconnect());
