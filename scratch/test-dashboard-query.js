const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

async function main() {
  const authId = "0c9a32eb-e87c-470c-884f-f59cc552a6cb";
  const now = new Date();
  console.log("Current date: ", now.toISOString());

  const account = await prisma.user.findUnique({
    where: { authId },
    include: { member: true },
  });
  console.log("Account: ", JSON.stringify(account, null, 2));

  if (!account) {
    console.log("ERROR: Account not found!");
    return;
  }

  const house = await prisma.house.findFirst();
  console.log("House: ", JSON.stringify(house, null, 2));

  if (!house) {
    console.log("ERROR: House not found!");
    return;
  }

  const month = await prisma.month.findFirst({
    where: {
      startsOn: { lte: now },
      endsOn: { gte: now },
      houseId: house.id,
    },
    include: {
      rentPayments: {
        include: {
          member: true,
          transactions: {
            include: {
              payer: true,
            },
            orderBy: {
              paidAt: "desc",
            },
          },
        },
        orderBy: {
          member: { name: "asc" },
        },
      },
      utilities: {
        include: { paidBy: true },
        orderBy: { dueDate: "asc" },
      },
      expenses: {
        include: { paidBy: true },
        orderBy: { createdAt: "desc" },
      },
    },
  });

  console.log("Month found: ", JSON.stringify(month, null, 2));
}

main()
  .catch((e) => console.error(e))
  .finally(() => prisma.$disconnect());
