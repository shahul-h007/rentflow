import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { z } from 'zod';

const saveReceiptSchema = z.object({
  houseId: z.string(),
  scannedById: z.string(),
  merchant: z.string().optional(),
  receiptNumber: z.string().optional(),
  date: z.string().optional(), // Store as ISO string in API, convert to Date
  subtotal: z.number().default(0),
  gst: z.number().default(0),
  serviceCharge: z.number().default(0),
  deliveryCharge: z.number().default(0),
  tip: z.number().default(0),
  discount: z.number().default(0),
  roundOff: z.number().default(0),
  grandTotal: z.number().default(0),
  imageUrl: z.string().optional(),
  rawOcrText: z.string().optional(),
  
  items: z.array(z.object({
    id: z.string(),
    name: z.string(),
    quantity: z.number(),
    unitPrice: z.number(),
    totalPrice: z.number(),
  })),

  assignments: z.array(z.object({
    receiptItemId: z.string(),
    memberId: z.string(),
    splitMethod: z.string(),
    quantity: z.number().optional(),
    percentage: z.number().optional(),
    amount: z.number().default(0),
  })),

  calculations: z.array(z.object({
    memberId: z.string(),
    foodAmount: z.number(),
    gstAmount: z.number(),
    discountAmount: z.number(),
    serviceAmount: z.number(),
    deliveryAmount: z.number(),
    tipAmount: z.number(),
    roundOffAmount: z.number(),
    finalAmount: z.number(),
  })),
});

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const data = saveReceiptSchema.parse(body);

    // 1. Transaction to save Receipt, Items, Assignments, Calculations, and generate Debts
    const receipt = await prisma.$transaction(async (tx) => {
      // Create Receipt
      const newReceipt = await tx.receipt.create({
        data: {
          houseId: data.houseId,
          scannedById: data.scannedById,
          merchant: data.merchant,
          receiptNumber: data.receiptNumber,
          date: data.date ? new Date(data.date) : null,
          subtotal: data.subtotal,
          gst: data.gst,
          serviceCharge: data.serviceCharge,
          deliveryCharge: data.deliveryCharge,
          tip: data.tip,
          discount: data.discount,
          roundOff: data.roundOff,
          grandTotal: data.grandTotal,
          imageUrl: data.imageUrl,
          rawOcrText: data.rawOcrText,
          parserVersion: '1.0.0',
        }
      });

      // Create Items
      for (const item of data.items) {
        await tx.receiptItem.create({
          data: {
            id: item.id, // preserve ID from client to link assignments
            receiptId: newReceipt.id,
            name: item.name,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            totalPrice: item.totalPrice,
          }
        });
      }

      // Create Assignments
      for (const assignment of data.assignments) {
        await tx.expenseAssignment.create({
          data: {
            receiptItemId: assignment.receiptItemId,
            memberId: assignment.memberId,
            splitMethod: assignment.splitMethod,
            quantity: assignment.quantity,
            percentage: assignment.percentage,
            amount: assignment.amount,
          }
        });
      }

      // Create Calculations
      for (const calc of data.calculations) {
        await tx.memberCalculation.create({
          data: {
            receiptId: newReceipt.id,
            memberId: calc.memberId,
            foodAmount: calc.foodAmount,
            gstAmount: calc.gstAmount,
            discountAmount: calc.discountAmount,
            serviceAmount: calc.serviceAmount,
            deliveryAmount: calc.deliveryAmount,
            tipAmount: calc.tipAmount,
            roundOffAmount: calc.roundOffAmount,
            finalAmount: calc.finalAmount,
          }
        });

        // 2. Settlement Integration: If final amount > 0, create Debt to house/pool
        if (calc.finalAmount > 0) {
          // For now, assuming the member who scanned the receipt paid the restaurant.
          // Everyone else owes the scanner.
          if (calc.memberId !== data.scannedById) {
            await tx.debt.create({
              data: {
                debtorId: calc.memberId,
                creditorId: data.scannedById,
                amount: calc.finalAmount,
                reason: `Food Split: ${data.merchant ?? 'Restaurant'}`,
              }
            });
          }
        }
      }

      // Create Expense record for historical tracking (Shared expense table)
      await tx.expense.create({
        data: {
          monthId: 'temp', // This would normally be looked up based on date/house
          paidById: data.scannedById,
          title: `Food @ ${data.merchant ?? 'Restaurant'}`,
          amount: data.grandTotal,
          splitType: 'CUSTOM', // Mapped from Food Splitter
        }
      });

      return newReceipt;
    });

    return NextResponse.json({ success: true, receiptId: receipt.id });

  } catch (error) {
    console.error('Save Receipt Error:', error);
    if (error instanceof z.ZodError) {
      return NextResponse.json({ success: false, errors: error.errors }, { status: 400 });
    }
    return NextResponse.json({ success: false, message: 'Internal Server Error' }, { status: 500 });
  }
}
