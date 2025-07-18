page 50255 "Replace Code"
{
    ApplicationArea = All;
    Caption = 'Replace code';
    PageType = List;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(Replacecode)
            {
                ApplicationArea = All;
                Caption = 'Replace Code';
                Image = Start;

                trigger OnAction()
                var
                    ReplacCode: Codeunit "Replace Code";
                begin
                    ReplacCode.Run();
                end;
            }
        }
    }

}
