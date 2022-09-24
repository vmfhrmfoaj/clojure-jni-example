import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

public class Test {
    static {
        try {
            InputStream libIn = Thread.currentThread().getContextClassLoader().getResourceAsStream("lib/libtest.so");
            File libFile = File.createTempFile("libtest.so", null);
            if (libIn == null) {
                throw new Exception("No library file");
            }
            libFile.deleteOnExit();
            Files.copy(libIn, libFile.toPath(), StandardCopyOption.REPLACE_EXISTING);

            System.load(libFile.getAbsolutePath());
        } catch (Exception e) {
            System.out.println("Unable to load JNI library");
            e.printStackTrace();
        }
    }

    public static native String print(String name);
}
