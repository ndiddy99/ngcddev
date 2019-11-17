import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.awt.image.IndexColorModel;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;

public class Converter {
    private ArrayList<Integer> palettes;
    private int[] imageData;
    private int imageWidth;
    private int imageHeight;
    private ArrayList<Tile> tiles;

    public Converter(String imageFileName) {
        File bmpFile = new File(imageFileName);
        palettes = new ArrayList<>();
        try {
            BufferedImage image = ImageIO.read(bmpFile);
            IndexColorModel colorModel;
            if (image.getColorModel() instanceof IndexColorModel) {
                colorModel = (IndexColorModel) image.getColorModel();
            }
            else {
                System.out.println("ERROR: Image not indexed color");
                return;
            }
            //---get palette from image---
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
                palettes.add(paletteEntry);
            }
            //---get image data---
            imageWidth = image.getWidth();
            imageHeight = image.getHeight();
            imageData = new int[imageWidth * imageHeight];
            imageData = image.getData().getPixels(0, 0, imageWidth, imageHeight, imageData);
            System.out.println(imageData.length);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void writeImage(String filename) {
        Path path = Paths.get(filename);
        byte[] tileData = Tile.imageToByteArr(imageData, imageWidth, imageHeight);
        try {
            Files.write(path, tileData);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    public void writePalette(String filename) {
        PrintWriter writer = null;
        try {
            writer = new PrintWriter(filename, "UTF-8");
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        writer.println(filename.substring(0, filename.indexOf('.')) + "Pal:");
        writer.print("\tdc.w ");
        for (int i = 0; i < palettes.size(); i++) {
            writer.print(String.format("$%04X,", palettes.get(i)));

        }
        writer.close();

    }
}
