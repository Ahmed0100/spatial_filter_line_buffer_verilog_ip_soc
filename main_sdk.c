#include "img_data.h"
#include "xparameters.h"
#include "xil_cache.h"
#include "xio.h"
#include "xuartlite.h"
#include "sleep.h"
#include "xaxidma.h"
#include "sleep.h"
#include "xintc.h"

u32 checkHalted(u32 baseAddr, u32 offset);

XIntc intc;
int num=0;;
void myISR(void* myDma) {
	XAxiDma* dma = (XAxiDma*)myDma;
	static linesNumSentSoFar=3;
	u8* imageData=XPAR_BRAM_0_BASEADDR;
	u32 imageWidth=20;
	u32 imageHeight=22;
	num++;
	xil_printf("%d\n",num);

	u32 status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);
	while(status != 1)
		status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);

	if(linesNumSentSoFar<imageHeight)
	{
		status = XAxiDma_SimpleTransfer(dma,imageData+(linesNumSentSoFar*imageWidth)*sizeof(u32),(imageWidth)*sizeof(u32),XAXIDMA_DMA_TO_DEVICE);
		if(status != XST_SUCCESS)
		{
			xil_printf("1- DMA Transfer Failed\n");
		}
	}
	linesNumSentSoFar++;
}

int main()
{
///////////////////////uart
	u32* imageData=XPAR_BRAM_0_BASEADDR;
	u32 receivedBytesNum=0;
	u32 totalReceivedBytesNum=0;
	u32 status=0;
	u32 imageSize = 400;
	u32 imageWidth=20;
	//UART init
	XUartLite_Config* myUartConfig= XUartLite_LookupConfig(XPAR_AXI_UARTLITE_0_DEVICE_ID);
	XUartLite myUart;
	status = XUartLite_CfgInitialize(&myUart,myUartConfig, myUartConfig->RegBaseAddr);
	if(status != XST_SUCCESS)
		xil_printf("UART init failed\n");
///////////////////////read image from memory
	for(int i=0;i<imageSize;i++)
	{
		XIo_Out32(imageData,img_data[i]);
		imageData++;
	}
	imageData = XPAR_BRAM_0_BASEADDR;
///////////////////////dma init
	XAxiDma_Config * myDmaConfig;
	XAxiDma myDma;
	myDmaConfig = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);
	status = XAxiDma_CfgInitialize(&myDma,myDmaConfig);
	if(status != XST_SUCCESS)
	{
		xil_printf("DMA Init Failed\n");
		return -1;
	}
/////////////interrupt start

	//intc init
	status = XIntc_Initialize(&intc,XPAR_INTC_0_DEVICE_ID);
	if(status != XST_SUCCESS) return XST_FAILURE;

	//connect the interrupt source to its handler
	status = XIntc_Connect(&intc,XPAR_AXI_INTC_0_SPATIAL_FILTER_IP_0_O_INTR_INTR,
			(XInterruptHandler)myISR,(void *)&myDma);
	if(status != XST_SUCCESS) return XST_FAILURE;

	//intc start
	status = XIntc_Start(&intc,XIN_REAL_MODE);
	if(status != XST_SUCCESS) return XST_FAILURE;

	//enable interrupt on ip
	XIntc_Enable(&intc,XPAR_AXI_INTC_0_SPATIAL_FILTER_IP_0_O_INTR_INTR);

	//enable microblaze interrupts
	Xil_ExceptionInit();
	//register intc interrupt into microblaze

	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			(Xil_ExceptionHandler)XIntc_InterruptHandler,
			&intc);
	//enable microblaze interrupts
	Xil_ExceptionEnable();

/////////////////////////interrupt end
	status = XAxiDma_SimpleTransfer(&myDma,(u32)imageData,(imageSize)*sizeof(u32),XAXIDMA_DEVICE_TO_DMA);
	if(status != XST_SUCCESS)
	{
		xil_printf("1- DMA Transfer Failed\n");
		return -1;
	}
	status = XAxiDma_SimpleTransfer(&myDma,(u32)imageData,(3*imageWidth)*sizeof(u32),XAXIDMA_DMA_TO_DEVICE);
	if(status != XST_SUCCESS)
	{
		xil_printf("2- DMA Transfer Failed\n");
		return -1;
	}
	status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);
	while(status != 1)
		status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);
	status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x34);
	while(status != 1)
		status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x34);

	while(1)
		;
//send image bytes to uart interface
//	u32 totalSentBytesNum=0;
//	u32 sentBytesNum=0;
//	while(totalSentBytesNum < imageSize)
//	{
//		sentBytesNum = XUartLite_Send(&myUart,imageData+(sizeof(u32)*totalSentBytesNum),imageSize);
//		totalSentBytesNum += sentBytesNum;
//	}
}
u32 checkHalted(u32 baseAddr,u32 offset)
{
//	u32 status;
//	status = XAxiDma_ReadReg(baseAddr,offset) &XAXIDMA_IDLE_MASK;
//	return status;
	return 1;
}
