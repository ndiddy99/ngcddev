import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.awt.image.IndexColorModel;
import java.io.File;
import java.io.IOException;

public class Converter {

    public Converter(String imageFileName) {
        File bmpFile = new File(imageFileName);
        try {
            BufferedImage image = ImageIO.read(bmpFile);
            IndexColorModel colorModel = (IndexColorModel)image.getColorModel();
            int size = colorModel.getMapSize();
            byte[] reds = new byte[size];
            byte[] greens = new byte[size];
            byte[] blues = new byte[size];
            colorModel.getReds(reds);
            colorModel.getGreens(greens);
            colorModel.getBlues(blues);
            for (int i = 0; i < size; i++) {
                //the ands are to make sure the bytes are treated as unsigned
                System.out.println("r: " + (reds[i] & 0xff) + " g: " + (greens[i] & 0xff) + " b: " + (blues[i] & 0xff));
                int red6Bits = (reds[i] & 0xff) >> 2;
                int green6Bits = (greens[i] & 0xff) >> 2;
                int blue6Bits = (blues[i] & 0xff) >> 2;
                int darkBit = 0;
                if (((red6Bits & 0x1) == 1) && ((green6Bits & 0x1) == 1) && ((blue6Bits & 0x1) == 1)) {
                    darkBit = 1;
                }
                int redLSB = (red6Bits & 2) >> 1;
                int greenLSB = (green6Bits & 2) >> 1;
                int blueLSB = (blue6Bits & 2) >> 1;
                //neo geo palette format:
                //DRGBRRRRGGGGBBBB
                int paletteEntry = (darkBit << 15) | (redLSB << 14) | (greenLSB << 13) | (blueLSB << 12) | ((red6Bits >> 2) << 8) |
                        ((green6Bits >> 2) << 4) | (blue6Bits >> 2);
                System.out.println("palette: " + paletteEntry);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
