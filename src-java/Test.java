import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

public class Test {
    static {
        String arch = System.getProperty("os.arch").toLowerCase();
        String os   = System.getProperty("os.name").toLowerCase();
        String libName = "test";
        String libPath = "lib/lib" + libName + "."+ arch +"_"+ os;
        try {
            InputStream libIn = Thread
                .currentThread()
                .getContextClassLoader()
                .getResourceAsStream(libPath);
            if (libIn == null) {
                throw new Exception("No library file: " + libPath);
            }
            File libFile = File.createTempFile(libName + "_", null);
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
