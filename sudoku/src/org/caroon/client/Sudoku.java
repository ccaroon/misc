package org.caroon.client;

import com.google.gwt.core.client.*;
import com.google.gwt.user.client.*;
import com.google.gwt.user.client.ui.*;
import com.google.gwt.xml.client.*;

public class Sudoku implements EntryPoint,ResponseTextHandler
{
    private GridTableListener gtl = new GridTableListener();
    private HorizontalPanel mainPanel = new HorizontalPanel();
    private Grid puzzle = new Grid(3,3);
    /**************************************************************************/
    public void onModuleLoad()
    {
        RootPanel.get().add(mainPanel);
        
        NumberButtonListener nbl = new NumberButtonListener(gtl);
        VerticalPanel vp = new VerticalPanel();
        for (int i = 1; i <= 9; i++)
        {
            Button b = new Button(String.valueOf(i));
            b.addClickListener(nbl);
            vp.add(b);
        }
        this.mainPanel.add(vp);
        
        this.formatGrid(this.puzzle,"150px");
        this.loadPuzzle("puzzle2.xml");
    }
    /**************************************************************************/
    private void drawPuzzle(Document data)
    {        
        int gindex = 0;
        NodeList glist = data.getElementsByTagName("grid");
        for (int row = 0; row < 3; row++)
        {
            for (int col = 0; col < 3; col++)
            {
                Grid grid = new Grid(3,3);
                grid.setBorderWidth(1);
                grid.addTableListener(this.gtl);
                this.formatGrid(grid,"50px");

                Node gdata = glist.item(gindex);
                NodeList clist = gdata.getChildNodes();
                for (int i = 0; i < clist.getLength(); i++)
                {
                    Node cdata = clist.item(i);
                    if (cdata.getNodeType() == Node.ELEMENT_NODE)
                    {
                        String cell_id = ((com.google.gwt.xml.client.Element)cdata).getAttribute("id");
                        int id = Integer.parseInt(cell_id) - 1;
                        int r = id / 3;
                        int c = id % 3;
// System.err.println("id: " + id + " r: " + r + " c: " + c);
                        NodeList cell_list = cdata.getChildNodes();
                        for (int x = 0; x < cell_list.getLength(); x++)
                        {
                            Node cell = cell_list.item(x);
                            if (cell.getNodeType() == Node.TEXT_NODE)
                            {
                                String value = ((Text)cell).getNodeValue();
                                grid.getCellFormatter().setStyleName(r,c,"sudoku-TableCellStatic");
                                grid.setHTML(r,c,value);
                            }
                        }
                    }
                }
                this.puzzle.setWidget(row,col,grid);
                gindex++;
            }
        }
        this.mainPanel.add(this.puzzle);
    }
    /**************************************************************************/
    private void loadPuzzle(String url)
    {
        boolean success = HTTPRequest.asyncGet(url, this);
        if (success == false)
        {
            DialogBox err = new DialogBox();
            err.setText("Could not load " + url);
            err.show();
        }
    }
    /**************************************************************************/
    private void formatGrid(Grid g, String wh)
    {
        int rows = g.getRowCount();
        int cols = g.getColumnCount();
        
        for (int r = 0; r < rows; r++)
        {
            for (int c = 0; c < cols; c++)
            {
                g.getCellFormatter().
                  setAlignment(r,c,
                               HasHorizontalAlignment.ALIGN_CENTER,
                               HasVerticalAlignment.ALIGN_MIDDLE);
                g.getCellFormatter().setWidth(r,c,wh);
                g.getCellFormatter().setHeight(r,c,wh);
            }
        }
    }
    /**************************************************************************/
    public void onCompletion(String rText)
    {
        Document d = XMLParser.parse(rText);
        this.drawPuzzle(d);
    }
    /**************************************************************************/
    class GridTableListener implements TableListener
    {
        int oldRow;
        int oldCol;
        Grid current;
        
        public void onCellClicked(SourcesTableEvents sender, int row, int col)
        {
            if (!((Grid)sender).getCellFormatter().getStyleName(row,col).equalsIgnoreCase("sudoku-TableCellStatic"))
            {
                if (this.current != null)
                {
                    this.current.getCellFormatter()
                        .removeStyleName(oldRow, oldCol, "sudoku-TableCellHilite");
                }

                this.oldRow  = row;
                this.oldCol  = col;
                this.current = (Grid)sender;
                
                this.current.getCellFormatter()
                    .setStyleName(row,col,"sudoku-TableCellHilite");
            }
            else
            {
                this.current.getCellFormatter()
                    .removeStyleName(oldRow, oldCol, "sudoku-TableCellHilite");
                this.current = null;
            }
        }
        
        public void setText(String text)
        {
            if (this.current != null)
            {
                this.current.setText(this.oldRow,this.oldCol, text);
            }
        }
    }
    /**************************************************************************/
    class NumberButtonListener implements ClickListener
    {
        GridTableListener gtl;
        
        public NumberButtonListener(GridTableListener g)
        {
            this.gtl = g;
        }
        
        public void onClick(Widget sender)
        {
            String num = ((Button)sender).getText();
            this.gtl.setText(num);
        }
    }
}
