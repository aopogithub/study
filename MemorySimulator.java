public class MemorySimulator {

    public static void main(String[] args) {
        if (args.length != 1) {
            System.err.println("Usage: java MemorySimulator <size_in_MB>");
            System.exit(1);
        }

        long sizeInMB = Long.parseLong(args[0]);
        long sizeInBytes = sizeInMB * 1024 * 1024;
        byte[] memoryBlock = new byte[(int)sizeInBytes];

        // 将数组填充以确保内存占用
        for (int i = 0; i < memoryBlock.length; i++) {
            memoryBlock[i] = (byte)i;
        }

        System.out.println("Allocated " + memoryBlock.length + " bytes (" + sizeInMB + " MB) of memory.");
        
        // 保持程序运行以便观察内存使用情况
        try {
            Thread.sleep(Long.MAX_VALUE);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.out.println("Interrupted");
        }
    }
}
