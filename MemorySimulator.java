
import java.nio.ByteBuffer;

public class MemorySimulator {

    public static void main(String[] args) {
        if (args.length != 1) {
            System.err.println("Usage: java MemorySimulator <size_in_MB>");
            System.exit(1);
        }

        long sizeInMB = Long.parseLong(args[0]);
        long sizeInBytes = sizeInMB * 1024 * 1024;
        ByteBuffer memoryBlock = ByteBuffer.allocateDirect((int)Math.min(sizeInBytes, Integer.MAX_VALUE));

        if (sizeInBytes > Integer.MAX_VALUE) {
            System.out.println("Warning: Only " + (Integer.MAX_VALUE / (1024 * 1024)) + " MB can be allocated using direct buffer.");
            sizeInBytes = Integer.MAX_VALUE;
        }

        // 将数组填充以确保内存占用
        for (int i = 0; i < sizeInBytes; i++) {
            memoryBlock.put((byte)i);
        }

        memoryBlock.rewind(); // 重置缓冲区的位置指针

        System.out.println("Allocated " + sizeInBytes + " bytes (" + sizeInMB + " MB) of memory.");
        
        // 保持程序运行以便观察内存使用情况
        try {
            Thread.sleep(Long.MAX_VALUE);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.out.println("Interrupted");
        }
    }
}
