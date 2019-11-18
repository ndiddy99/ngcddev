import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.awt.image.IndexColorModel;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;

public class Converter {
    private ArrayList<Byte> tiles;

    public Converter() {
        tiles = new ArrayList<>();
    }

    public void addImage(String filename) {
        File bmpFile = new File(filename);
        try {
            BufferedImage image = ImageIO.read(bmpFile);
            int imageWidth = image.getWidth();
            int imageHeight = image.getHeight();
            int[] imageData = new int[imageWidth * imageHeight];
            imageData = image.getData().getPixels(0, 0, imageWidth, imageHeight, imageData);
            byte[] tileData = Tile.imageToByteArr(imageData, imageWidth, imageHeight);
            for (int i = 0; i < tileData.length; i++) {
                tiles.add(tileData[i]);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    public void writeImages(String filename) {
        if (tiles.size() == 0) {
            return;
        }
        Path path = Paths.get(filename);
        byte[] tilesArr = new byte[tiles.size()];
        for (int i = 0; i < tilesArr.length; i++) {
            tilesArr[i] = tiles.get(i);
        }
        try {
            Files.write(path, tilesArr);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    public void writePalette(String inFile, String outFile) {
        File bmpFile = new File(inFile);
        ArrayList<Integer> palettes = new ArrayList<>();
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
        } catch (Exception e) {
            e.printStackTrace();
        }

        PrintWriter writer = null;
        try {
            writer = new PrintWriter(outFile, "UTF-8");
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        writer.print(outFile.substring(0, outFile.indexOf('.')) + "Pal:");
        for (int i = 0; i < palettes.size(); i+= 8) {
            //if a row is entirely zeroes, assume we've reached the end of a palette definition
            boolean allZeroes = true;
            for (int j = 0; j < 8; j++) {
                if (palettes.get(i + j) != 0) {
                    allZeroes = false;
                    break;
                }
            }
            if (allZeroes) {
                writer.close();
                return;
            }
            writer.print("\n\tdc.w ");
            for (int j = 0; j < 8; j++) {
                writer.print(String.format("$%04X,", palettes.get(i + j)));
            }
        }
        writer.close();

    }
}
