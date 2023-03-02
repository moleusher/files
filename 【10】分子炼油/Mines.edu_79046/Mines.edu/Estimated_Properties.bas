Attribute VB_Name = "Module_EstimatedProperties"
Option Explicit

Function FlashPt(T10 As Double) As Variant
'
'   Function to estimate the flash point temperature based on API Procedure 2B7.1.
'
'   Written 08/29/2003 (JL Jechura).
'
Dim T10R As Double

'
'   Convert temperature from °F to °R.
    T10R = T10 + 459.67
    
'
'   Calculate.
    FlashPt = 1 / (-0.014568 + 2.84947 / T10R + 0.001903 * Log(T10R)) - 459.67
    
End Function
Function MolWt(SpGr As Double, BPT_degR As Double) As Variant
Attribute MolWt.VB_Description = "Estimates molecular weight of a petroleum fraction using Riazzi-Daubert method. Input values are Specific Gravity (60/60) and the normal boiling point (°R)."
'
'   REF:  API TECHNICAL DATA BOOK -- PETROLEUM REFINING, 4TH ED.
'              PP. 2.15, 4.57, 4.65, 7.133-134
      
    MolWt = 20.486 * BPT_degR ^ 1.26007 * SpGr ^ 4.98308 * _
        Exp(0.0001165 * BPT_degR + (-7.78712 + 0.0011582 * BPT_degR) * SpGr)

End Function

Function CriticalPressure(SpGr As Double, BPT_degR As Double) As Variant
Attribute CriticalPressure.VB_Description = "Estimates critical pressure (psia) of a petroleum fraction using Riazzi-Daubert method. Input values are Specific Gravity (60/60) and normal boiling point (°R)."
'
'   REF:  API TECHNICAL DATA BOOK -- PETROLEUM REFINING, 4TH ED.
'              PP. 2.15, 4.57, 4.65, 7.133-134
      
    CriticalPressure = 6162000# / BPT_degR ^ 0.4844 * SpGr ^ 4.0846 * _
        Exp(-0.004725 * BPT_degR + (-4.8014 + 0.0031939 * BPT_degR) * SpGr)
        
End Function

Function CriticalTemperature(SpGr As Double, BPT_degR As Double) As Variant
Attribute CriticalTemperature.VB_Description = "Estimates critical temperature (°R) of a petroleum fraction using Riazzi-Daubert method. Input values are Specific Gravity (60/60) and normal boiling point (°R)."
'
'   REF:  API TECHNICAL DATA BOOK -- PETROLEUM REFINING, 4TH ED.
'              PP. 2.15, 4.57, 4.65, 7.133-134
      
    CriticalTemperature = 10.6443 * BPT_degR ^ 0.81067 * SpGr ^ 0.53691 * _
        Exp(-0.00051747 * BPT_degR + (-0.54444 + 0.00035995 * BPT_degR) * SpGr)
        
End Function

'   Functions for gross & net heats of combustion are from API Procedure 14A1.3
'   from the API Technical Data Book -- Refining.
'   Units on the heats of combustion are Btu/lb.

Function GrossHeatCombustion(APIGravity As Double, WPC_Sulfur As Double, WPC_Inerts As Double, WPC_Water As Double) As Variant
Attribute GrossHeatCombustion.VB_Description = "Estimates gross (higher) heating value of a petroleum fraction. Input values are API Gravity, wt% sulfur (enter -1 to estimate), wt% inerts (enter -1 to estimate), & wt% water (enter 0 if unknown)."

    Dim Heat                As Double
    Dim SulfurCorrection    As Double
    Dim InertsCorrection    As Double
    
'   Uncorrected gross heat of cumbuston @ 60°F.
    Heat = 17672 + (66.6 - (0.316 + 0.0014 * APIGravity) * APIGravity) * APIGravity

'   Correction for sulfur, inerts, & water.
    If WPC_Sulfur < 0 Then
        SulfurCorrection = 0
    Else
        SulfurCorrection = WPC_Sulfur - AveSulfur(APIGravity)
    End If
    If WPC_Inerts < 0 Then
        InertsCorrection = 0
    Else
        InertsCorrection = WPC_Inerts - AveInerts(APIGravity)
    End If
    
    Heat = Heat * (1 - 0.01 * (WPC_Water + SulfurCorrection + InertsCorrection)) + 40.5 * SulfurCorrection
    GrossHeatCombustion = Heat
    
End Function

Function NetHeatCombustion(APIGravity As Double, WPC_Sulfur As Double, WPC_Inerts As Double, WPC_Water As Double) As Variant
Attribute NetHeatCombustion.VB_Description = "Estimates net (lower) heating value of a petroleum fraction. Input values are API Gravity, wt% sulfur (enter -1 to estimate), wt% inerts (enter -1 to estimate), & wt% water (enter 0 if unknown)."

    Dim Heat                As Double
    Dim SulfurCorrection    As Double
    Dim InertsCorrection    As Double
    
'   Uncorrected net heat of cumbuston @ 60°F.
    Heat = 16796 + (54.5 - (0.217 + 0.0019 * APIGravity) * APIGravity) * APIGravity

'   Correction for sulfur, inerts, & water.
    If WPC_Sulfur < 0 Then
        SulfurCorrection = 0
    Else
        SulfurCorrection = WPC_Sulfur - AveSulfur(APIGravity)
    End If
    If WPC_Inerts < 0 Then
        InertsCorrection = 0
    Else
        InertsCorrection = WPC_Inerts - AveInerts(APIGravity)
    End If
    
    Heat = Heat * (1 - 0.01 * (WPC_Water + SulfurCorrection + InertsCorrection)) + 40.5 * SulfurCorrection - 10.53 * WPC_Water
    NetHeatCombustion = Heat
    
End Function

Private Function AveSulfur(APIGravity As Double) As Double

    Dim G   As Double
    
    G = Max(35, Min(APIGravity, 0))
    AveSulfur = 2.948 + (-0.1282 + 0.001488 * G) * G

End Function


Private Function AveInerts(APIGravity As Double) As Double

    Dim G   As Double
    
    G = Max(35, Min(APIGravity, 0))
    AveInerts = 1.14 + (-0.023274 + 0.0002262 * G) * G

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


