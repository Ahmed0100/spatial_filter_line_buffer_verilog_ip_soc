# spatial_filter_line_buffer_verilog_ip_soc
A spatial filter ip that does edge detection on a parameterized gray scale bmp image by convluting the image with a SOBEL kernel. A microblaze system reads the image from an array and writes it to a bram memory, DMA sends the image bytes to the spatial filter IP and then the DMA writes the data back to the bram memory.
