import java.util.ArrayList;

public class Tile {
    //represents Neo Geo sprite tile
    //info on tile format: https://wiki.neogeodev.org/index.php?title=Sprite_graphics_format
    byte[] topLeft;
    byte[] topRight;
    byte[] botLeft;
    byte[] botRight;
    static final int BLOCK_SIZE = 32;

    public Tile(byte[] tileData) {
        topLeft = new byte[BLOCK_SIZE];
        topRight = new byte[BLOCK_SIZE];
        botLeft = new byte[BLOCK_SIZE];
        botRight = new byte[BLOCK_SIZE];
        populateArray(tileData, topLeft, 0, 0);
        populateArray(tileData, topRight, 8, 0);
        populateArray(tileData, botLeft, 0, 8);
        populateArray(tileData, botRight, 8, 8);
    }

    private void populateArray(byte[] image, byte[] destination, int xStart, int yStart) {
        int xFinish = xStart + 8;
        int yFinish = yStart + 8;
        int bitplane0, bitplane1, bitplane2, bitplane3;
        int count = 0;
        for (int y = yStart; y < yFinish; y++) {
            bitplane0 = 0; bitplane1 = 0; bitplane2 = 0; bitplane3 = 0;
            for (int x = xStart; x < xFinish; x++) {
                int currPixel = (image[y * 16 + x] & 0xff) & 0xf;
                bitplane0 >>= 1;
                bitplane1 >>= 1;
                bitplane2 >>= 1;
                bitplane3 >>= 1;
                if ((currPixel & 0x1) != 0) {
                    bitplane0 |= 0x80;
                }
                if ((currPixel & 0x2) != 0) {
                    bitplane1 |= 0x80;
                }
                if ((currPixel & 0x4) != 0) {
                    bitplane2 |= 0x80;
                }
                if ((currPixel & 0x8) != 0) {
                    bitplane3 |= 0x80;
                }
            }
            //bitplanes are stored as 1, 0, 3, 2
            destination[count++] = (byte)(bitplane1 & 0xff);
            destination[count++] = (byte)(bitplane0 & 0xff);
            destination[count++] = (byte)(bitplane3 & 0xff);
            destination[count++] = (byte)(bitplane2 & 0xff);
        }
    }

    public byte[] getBytes() {
        byte[] tile = new byte[BLOCK_SIZE * 4];
        int count = 0;
        for (int i = 0; i < BLOCK_SIZE; i++) {
            tile[count++] = topRight[i];
        }
        for (int i = 0; i < BLOCK_SIZE; i++) {
            tile[count++] = botRight[i];
        }
        for (int i = 0; i < BLOCK_SIZE; i++) {
            tile[count++] = topLeft[i];
        }
        for (int i = 0; i < BLOCK_SIZE; i++) {
            tile[count++] = botLeft[i];
        }
        return tile;
    }

    public static byte[] imageToByteArr(int[] image, int width, int height) {
        ArrayList<Tile> tiles = new ArrayList<>();
        byte[] chunkBytes = new byte[16 * 16];
        int chunkBytesCount;
        byte[] sprFile = new byte[(width / 16) * (height / 16) * (4 * BLOCK_SIZE)];
        int sprFileCount = 0;
        for (int y = 0; y <= (height - 16); y += 16) {
            for (int x = 0; x <= (width - 16); x += 16) {
                chunkBytesCount = 0;
                for (int i = 0; i < 16; i++) {
                    for (int j = 0; j < 16; j++) {
                        chunkBytes[chunkBytesCount++] = (byte)(image[(y + i) * width + (x + j)] & 0xff);
                    }
                }
                Tile tile = new Tile(chunkBytes);
                byte[] tileBytes = tile.getBytes();
                for (int i = 0; i < tileBytes.length; i++) {
                    sprFile[sprFileCount++] = tileBytes[i];
                }
            }
        }
        return sprFile;
    }

}
