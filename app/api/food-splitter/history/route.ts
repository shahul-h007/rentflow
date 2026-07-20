import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const houseId = searchParams.get('houseId');

    if (!houseId) {
      return NextResponse.json({ error: 'houseId is required' }, { status: 400 });
    }

    const receipts = await prisma.receipt.findMany({
      where: {
        houseId: houseId,
      },
      orderBy: {
        createdAt: 'desc',
      },
      include: {
        scannedBy: {
          select: { name: true }
        },
        items: {
          include: {
            assignments: {
              include: {
                member: { select: { name: true } }
              }
            }
          }
        }
      }
    });

    return NextResponse.json({ receipts });
  } catch (error) {
    console.error('Fetch History Error:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
