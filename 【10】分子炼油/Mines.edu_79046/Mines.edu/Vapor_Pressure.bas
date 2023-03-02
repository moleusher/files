Attribute VB_Name = "Module_VaporPressure"
Option Explicit
Global Const Tb0 = 200#
Global Const WatK0 = 12#
Global Const F0 = 2.5
Global Const X12 = 0.002184346
Global Const X23 = 0.001201343
Global Const X0 = 0.0002867
Global Const X1 = 748.1
Global Const C11 = 3000.538
Global Const C12 = 2663.129
Global Const C13 = 2770.085
Global Const C21 = 6.76156
Global Const C22 = 5.994296
Global Const C23 = 6.412631
Global Const C31 = 43#
Global Const C32 = 95.76
Global Const C33 = 36#
Global Const C41 = 0.987672
Global Const C42 = 0.972546
Global Const C43 = 0.989679
Global Const nMax = 25
Global Const dTbTol = 0.01
Global Const Ppsia = 14.69595
Global Const PmmHg = 760#
Global Const Pbar = 1.01325
Global Const T0R = 459.67

      
Function APIVaporPressure_mmHg _
    (degF As Double, BPdegF As Double, Optional WatsonK As Double = 12#) _
As Variant
Attribute APIVaporPressure_mmHg.VB_Description = "Maxwell-Bonnell vapor pressure (in mmHg) of a petroleum fraction.  Input temperature of interest (degF) & normal boiling point (BPdegF).  Watson K factor (WatsonK) optional; if not given, default value of 12 used."
'
'   This routine estimates the vapor pressure of a petroleum
'   fraction using the API computer version of the Maxwell-Bonnell
'   method.  The procedure was adjusted slightly to give a smooth
'   transition of the vapor pressure between the three sets of
'   equations and to get 760 mm Hg vapor pressure when the temperature
'   is set equal to the boiling point.
'
'   Ref:  Procedure 5a1.13
'         API Technical Data Book -- Petroleum Refining, 4th ed., 1983
'
'   Modified from existing Fortran code, 04/03/96 (JL Jechura).
'   Modified 09/10/02 (JL Jechura).  Changed to directly give the vapor
'       pressure in units of mmHg instead of psia.
'   Modified 07/27/10 (JL Jechura). Modified value of X1 to match recent
'       versions of API Technical Data Book.
'
    Dim C1 As Double
    Dim C2 As Double
    Dim C3 As Double
    Dim C4 As Double
    Dim TbR As Double
    Dim DTb As Double
    Dim F As Double
    Dim NN As Integer
    Dim TbC As Double
    Dim x As Double
    Dim PVap As Double
    Dim TR As Double
    Dim N As Integer
    Dim NewDTb As Double
    
'   Set up error handler.
    On Error GoTo VaporPressureError

' Initialize the boiling point correction factor.  Calculate the
' Watson K-factor portion of the 'F' term in correction factor
' function.
      
      TbR = BPdegF + T0R
      DTb = 0#
      If (degF <= BPdegF) Then
        F = 1#
      Else
        F = Min(1#, Max((BPdegF - Tb0) / Tb0, 0#))
      End If
      F = F0 * F * (WatsonK - WatK0)

' Iterate on the boiling point correction factor.
      
      TR = degF + T0R
      For NN = 1 To nMax

' Determine the set of constants to use in the correlation.
        
        TbC = TbR - DTb
        x = (1# / TR - X0) / (1# / TbC - X0) / X1
        N = 1
        If (x <= X12) Then N = 2
        If (x < X23) Then N = 3
        Select Case N
        Case 1
            C1 = C11
            C2 = C21
            C3 = C31
            C4 = C41
        Case 2
            C1 = C12
            C2 = C22
            C3 = C32
            C4 = C42
        Case 3
            C1 = C13
            C2 = C23
            C3 = C33
            C4 = C43
        End Select
        
'  Calculate the vapor pressure.
        
        PVap = 10 ^ ((C1 * x - C2) / (C3 * x - C4))
 
'  Calculate new boiling point correction factor.

        NewDTb = F * Log10(PVap / PmmHg)
        If (Abs(NewDTb - DTb) < dTbTol) Then Exit For
        DTb = NewDTb

    Next
    ' MsgBox "NN=" & NN
    APIVaporPressure_mmHg = PVap
    Exit Function
    
VaporPressureError:
    APIVaporPressure_mmHg = "#ERR!"
    Exit Function
    
End Function

Function APIVaporPressure_psia _
    (degF As Double, BPdegF As Double, Optional WatsonK As Double = 12#) _
As Variant
Attribute APIVaporPressure_psia.VB_Description = "Maxwell-Bonnell vapor pressure (in psia) of a petroleum fraction.  Input temperature of interest (degF) & normal boiling point (BPdegF).  Watson K factor (WatsonK) optional; if not given, default value of 12 used."
'
'   This routine estimates the vapor pressure of a petroleum
'   fraction using the API computer version of the Maxwell-Bonnell
'   method & returns it in units of psia.  Calls the more basic function
'   "APIVaporPressure_mmHg".
'
'   Modified 09/10/02 (JL Jechura).
'
    APIVaporPressure_psia = (Ppsia / PmmHg) * APIVaporPressure_mmHg(degF, BPdegF, WatsonK)

End Function

Function BP_degF _
    (P As Double, BaseDegF As Double, BaseP As Double, Optional PUnits As String = "psia", _
    Optional WatsonK As Double = 12#) _
As Variant
Attribute BP_degF.VB_Description = "Maxwell-Bonnell boiling point (in °F) of a petroleum fraction. Input pressure of interest (P) & measured temperature (BaseDegF) & associated pressure (BaseP). Enter string for pressure units (PUnits). Watson K factor (WatsonK) is optional; if not given, default value of 12 used."
'
'
'   This routine estimates the boiling point of a petroleum
'   fraction using the API computer version of the Maxwell-Bonnell
'   method.  The routine "APIVaporPressure_psia" is called in an
'   iterative fashion to determine the normal BP; this is used to
'   determine the BP at the given pressure.
'
'   Written 06/20/97 (J.L. Jechura)
'   Revised 09/10/02 (JL Jechura).  Nows uses mmHg pressure directly.
'
    Dim N           As Integer
    Dim BP          As Double
    Dim BPOld       As Double
    Dim CalcPsia    As Double
    Dim CalcPsiaOld As Double
    Dim Slope       As Double
    Dim Resid       As Double
    Dim Correct     As Double
    Dim ABP         As Double
    Dim BasePsia    As Double
    Dim psia        As Double

'   Set up error handler.
    On Error GoTo BPError
    
'   Determine the pressure units given & convert to psia.
    Select Case LCase(PUnits)
    Case "psia", "psi", "lb/in2"
        BasePsia = BaseP
        psia = P
    Case "mmhg", "torr"
        BasePsia = BaseP * Ppsia / PmmHg
        psia = P * Ppsia / PmmHg
    Case "bar"
        BasePsia = BaseP * Ppsia / Pbar
        psia = P * Ppsia / Pbar
    Case "atm"
        BasePsia = BaseP * Ppsia
        psia = P * Ppsia
    Case Else
        BP_degF = "PUnits!"
        Exit Function
    End Select
    
' Determine the atmospheric boiling point.
    BPOld = BaseDegF
    CalcPsiaOld = APIVaporPressure_psia(BaseDegF, BPOld, WatsonK)
    If CalcPsiaOld > BasePsia Then
        BP = BPOld - 10#
    Else
        BP = BPOld + 10#
    End If
    For N = 1 To nMax
        CalcPsia = APIVaporPressure_psia(BaseDegF, BP, WatsonK)
        Slope = (CalcPsia - CalcPsiaOld) / (BP - BPOld)
        Resid = CalcPsia - BasePsia
        Correct = -Resid / Slope
        If Abs(Correct) < dTbTol Then Exit For
        If Correct > 50 Then
            Correct = 50
        ElseIf Correct < -50 Then
            Correct = -50
        End If
        ' MsgBox "Correct = " & Correct
        BPOld = BP
        CalcPsiaOld = CalcPsia
        BP = BP + Correct
    Next
    ABP = BP
    
' Adjust final temperature to match new pressure.
    BPOld = BP
    CalcPsiaOld = APIVaporPressure_psia(BPOld, ABP, WatsonK)
    If CalcPsiaOld > psia Then
        BP = BPOld - 10#
    Else
        BP = BPOld + 10#
    End If
    For N = 1 To nMax
        CalcPsia = APIVaporPressure_psia(BP, ABP, WatsonK)
        Slope = (CalcPsia - CalcPsiaOld) / (BP - BPOld)
        Resid = CalcPsia - psia
        Correct = -Resid / Slope
        If Abs(Correct) < dTbTol Then Exit For
        If Correct > 50 Then
            Correct = 50
        ElseIf Correct < -50 Then
            Correct = -50
        End If
        ' MsgBox "Correct = " & Correct
        BPOld = BP
        CalcPsiaOld = CalcPsia
        BP = BP + Correct
    Next
    BP_degF = BP
    Exit Function
    
BPError:
    BP_degF = "#ERR!"
    Exit Function
    
End Function


Private Function Max(ParamArray Values() As Variant) As Variant
'
'   Routine to return the maximum of an arbitrary number of values.
'
'   Assembled by J. L. Jechura.  Last modified 10/26/94.
'   Modified 07/19/2001 (J.L. Jechura). Changed to process an arbitrary number
'       of values.
'
Dim i As Long
Dim j As Long

    j = LBound(Values)
    Max = Values(j)
    For i = (j + 1) To UBound(Values)
        If Values(i) > Max Then
            Max = Values(i)
        End If
    Next i

End Function

Private Function Min(ParamArray Values() As Variant) As Variant
'
'   Routine to return the minimum of an arbitrary number of values.
'
'   Assembled by J. L. Jechura.  Last modified 10/26/94.
'   Modified 07/19/2001 (J.L. Jechura). Changed to process an arbitrary number
'       of values.
'
Dim i As Long
Dim j As Long

    j = LBound(Values)
    Min = Values(j)
    For i = (j + 1) To UBound(Values)
        If Values(i) < Min Then
            Min = Values(i)
        End If
    Next i

End Function


Private Function Log10(x As Double) As Double
    Log10 = Log(x) / Log(10#)
End Function
