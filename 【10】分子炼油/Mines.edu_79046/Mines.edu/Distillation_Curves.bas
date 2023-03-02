Attribute VB_Name = "Module_DistillationCurves"
Option Explicit

Function Interpolate_DistCurve _
    (Value As Variant, YieldInput As Boolean, degF_Data As Object, pctYield_Data As Object, _
    Optional bSpline As Boolean = False) _
As Variant
Attribute Interpolate_DistCurve.VB_Description = "Interpolates distillation curve assuming 'S' shape for yield vs temperature. 'YieldInput' Boolean to tell whether a temperature Value or Yield Value has been input."
'
'   Function to interpolate within distillation curve data to determine temperature or
'   yield.  The yield data is straightened by converting to a Gaussian normal variable
'   (as in the use of probability graph paper) using the NORMSINV & NORMSDIST worksheet
'   functions.
'
'   Written 10/24/2002 (JL Jechura).
'   Modified 10/29/2008 (JL Jechura). Check that the temperature & yield arrays are
'       in monotonic ascending order. If not, return error code. Do this at same time as
'       copying values from objects to arrays.
'   Modified 5/21/2013 (JL Jechura). Allow spline interpolation on the transformed yield vs.
'       temperatures.
'

Dim nData As Long, iRow As Integer, NewValue As Variant, Fraction As Double
Dim TransformedYields() As Variant, degFs() As Variant

'
'   Ensure that the arrays have the same sizes.

    nData = degF_Data.Count
    If (nData <> pctYield_Data.Count) Then
        Interpolate_DistCurve = "#ArrayLengths!"
        Exit Function
    ElseIf (nData <= 1) Then
        Interpolate_DistCurve = "#NumberOfValues!"
        Exit Function
    End If
    
'
'   Ensure that the temperature and yield values are monotonically increasing in value.
    ReDim degFs(1 To nData)
    degFs(1) = degF_Data(1)
    For iRow = 2 To nData
        degFs(iRow) = degF_Data(iRow)
        If (degF_Data(iRow) <= degF_Data(iRow - 1)) Then
            Interpolate_DistCurve = "#OrderTemperature!"
            Exit Function
        End If
    Next iRow
    
    ReDim TransformedYields(1 To nData)
    TransformedYields(1) = WorksheetFunction.NormSInv(pctYield_Data(1) / 100#)
    For iRow = 2 To nData
        TransformedYields(iRow) = WorksheetFunction.NormSInv(pctYield_Data(iRow) / 100#)
        If (TransformedYields(iRow) <= TransformedYields(iRow - 1)) Then
            Interpolate_DistCurve = "#OrderYield!"
            Exit Function
        End If
    Next iRow
    
'
'   Do the interpolation.
'   Find temperature for given yield.
    If (YieldInput) Then
        NewValue = WorksheetFunction.NormSInv(Value / 100#)
        If (bSpline) Then
            NewValue = CubicSpline(NewValue, TransformedYields, degFs, nData)
        Else
            NewValue = LinearInterpolate(NewValue, TransformedYields, degFs)
        End If
'
'   Find yield for given temperature.
    Else
        If (bSpline) Then
            NewValue = CubicSpline(Value, degFs, TransformedYields, nData)
        Else
            NewValue = LinearInterpolate(Value, degFs, TransformedYields)
        End If
        NewValue = WorksheetFunction.NormSDist(NewValue) * 100#
    End If
    
'
'   Set value & return.
    Interpolate_DistCurve = NewValue
    
End Function
    
Private Function LinearInterpolate _
    (X_Value As Variant, Known_Xs() As Variant, Known_Ys() As Variant) _
As Variant
'
'   Function to do linear interpolation within two arrays.
'
'   Written 07/06/2001 (J.L. Jechura).
'   Modified 10/24/2002 (JL Jechura) to split up the Excel specific code from the general
'       array code.
'
Dim iRow As Integer, Fraction As Double

'
'   Determine the row that starts to bracket the answer.
'   Determine the interpolated x_value.

    iRow = Locate(X_Value, Known_Xs)
    Fraction = (X_Value - Known_Xs(iRow)) / (Known_Xs(iRow + 1) - Known_Xs(iRow))
    LinearInterpolate = Known_Ys(iRow) + (Known_Ys(iRow + 1) - Known_Ys(iRow)) * Fraction
    
End Function

Private Function Locate(X_Value As Variant, Known_Xs() As Variant) As Variant
'
'   Returns the index value in "known_xs" that precedes the given "x_value".  Bisection method
'   used.
'
'   Based on Fortran code in _Numerical Recipes in Fortran 77, 2nd ed._, WH Press, SA Teukolsky, WT Vetterling, & BP Flannery, 1992, pg. 111.
'
'   Written 08/31/2001 (JL Jechura).
'
Dim jFirst As Long, jLast As Long
Dim jLow As Long, jMid As Long, jUpper As Long
Dim bAscend As Boolean

'
' Initialize lower & upper limits.  Initialize logical flag for ascending data.
' Code using VB arrays.
    jFirst = LBound(Known_Xs)
    jLast = UBound(Known_Xs)
    
    jLow = jFirst - 1
    jUpper = jLast + 1
    bAscend = (Known_Xs(jLast) >= Known_Xs(jFirst))
    
    Do While ((jUpper - jLow) > 1)
        jMid = (jUpper + jLow) / 2
        If (bAscend = (X_Value >= Known_Xs(jMid))) Then
            jLow = jMid
        Else
            jUpper = jMid
        End If
    Loop

    Locate = WorksheetFunction.Max(jFirst, WorksheetFunction.Min(jLow, jLast - 1))

End Function

Private Function CubicSpline _
    (X_Value As Variant, Known_Xs() As Variant, Known_Ys() As Variant, nValues As Long) _
As Variant
'
'   Function to do spline interpolation between two arrays.
'
'   Ref:    Digital Computing & Numerical Methods (with FORTRAN-IV, WATFOR, & WATFIV Programming)
'           Brice Carnahan & James O. Wilkes
'           John Wiley & Sons, 1973
'           pp 307 - 309
'
'   Written 10/18/2009 (J.L. Jechura) based on the routine "LinearInterpolate".
'
Dim Phi() As Double, DeltaX() As Double, DeltaY() As Double, _
    Diagonal() As Double, Upper() As Double, Lower() As Double, Slope As Double
Dim i As Long, iRow As Long
'
'
'   Determine number of points. Redimension the arrays for this number of points.
    ReDim Phi(1 To nValues), DeltaX(1 To nValues), DeltaY(1 To nValues), _
            Diagonal(1 To nValues), Upper(1 To nValues), Lower(1 To nValues), RHS(1 To nValues)
    
'
'   Calculate the differences in the X & Y values. Determine the interval in which the given X_Value occurs.
    DeltaX(1) = Known_Xs(2) - Known_Xs(1)
    DeltaY(1) = Known_Ys(2) - Known_Ys(1)
    iRow = 1
    For i = 2 To (nValues - 1)
        DeltaX(i) = Known_Xs(i + 1) - Known_Xs(i)
        DeltaY(i) = Known_Ys(i + 1) - Known_Ys(i)
    Next i
    
'
'   Set up the coefficients for the simulataneous equations. Solve for the Phi values.
    Upper(1) = 0
    Lower(1) = 0
    Diagonal(1) = 1
    Phi(1) = 0
    For i = 2 To (nValues - 1)
        Upper(i) = 1
        Lower(i) = DeltaX(i - 1) / DeltaX(i)
        Diagonal(i) = 2 * (1 + Lower(i))
        Phi(i) = 6 * (DeltaY(i) / DeltaX(i) - DeltaY(i - 1) / DeltaX(i - 1)) / DeltaX(i)
    Next i
    Upper(nValues) = 0
    Lower(nValues) = 0
    Diagonal(nValues) = 1
    Phi(nValues) = 0
    Call TriDiag(Lower, Diagonal, Upper, Phi, Phi, nValues)

'
'   Determine the row that starts to bracket the answer.
'   Determine the interpolated x_value. If extrapolating then do so with the slope at the terminal point.

    iRow = Locate(X_Value, Known_Xs)
    If (iRow = 1 And (X_Value - Known_Xs(2)) / (Known_Xs(1) - Known_Xs(2)) > 1) Then
        Slope = (-(Known_Xs(2) - Known_Xs(1)) ^ 2 * Phi(1)) / DeltaX(1) / 2 + _
            (Known_Ys(2) / DeltaX(1) - DeltaX(1) * Phi(2) / 6) - _
            (Known_Ys(1) / DeltaX(1) - DeltaX(1) * Phi(1) / 6)
        CubicSpline = Known_Ys(1) + Slope * (X_Value - Known_Xs(1))
    ElseIf (iRow = nValues - 1 And (X_Value - Known_Xs(iRow)) / (Known_Xs(iRow + 1) - Known_Xs(iRow)) > 1) Then
        Slope = ((Known_Xs(iRow + 1) - Known_Xs(iRow)) ^ 2 * Phi(iRow + 1)) / DeltaX(iRow) / 2 + _
            (Known_Ys(iRow + 1) / DeltaX(iRow) - DeltaX(iRow) * Phi(iRow + 1) / 6) - _
            (Known_Ys(iRow) / DeltaX(iRow) - DeltaX(iRow) * Phi(iRow) / 6)
        CubicSpline = Known_Ys(iRow + 1) + Slope * (X_Value - Known_Xs(iRow + 1))
    Else
        CubicSpline = ((Known_Xs(iRow + 1) - X_Value) ^ 3 * Phi(iRow) + (X_Value - Known_Xs(iRow)) ^ 3 * Phi(iRow + 1)) / DeltaX(iRow) / 6 + _
            (Known_Ys(iRow + 1) / DeltaX(iRow) - DeltaX(iRow) * Phi(iRow + 1) / 6) * (X_Value - Known_Xs(iRow)) + _
            (Known_Ys(iRow) / DeltaX(iRow) - DeltaX(iRow) * Phi(iRow) / 6) * (Known_Xs(iRow + 1) - X_Value)
    End If
    
    End Function

Sub TriDiag _
    (a() As Double, b() As Double, c() As Double, d() As Double, v() As Double, n As Long)
'
'   Routine to solve for a vector u(1 to n) in the tridiagonal linear set given by Av=d where:
'       a(2 to n) is the lower diagonal
'       b(1 to n) is the diagonal
'       c(1 to n-1) is the upper diagonal.
'
'   1st Source: Applied Numerical Methods
'               B. Carnahan, H.A. Luther, J.O. Wilkes
'               John Wiley & Sons, 1969
'               pp 441-446
'   2nd Source: Numerical Recipes in Fortran 77, 2nd ed.
'               W.H. Press, S.A. Teukolsky, W.T. Vetterling, B.P. Flannery
'               Cambridge University Press, 1996
'               pp 42-43
'   Written & last updated 10/18/2009 (JL Jechura).
'
Dim i As Long
Dim beta() As Double
Dim gamma() As Double
'
' Size gamma appropriate for problem
    ReDim beta(1 To n)
    ReDim gamma(1 To n)
    
'
' Decomposition & forward substituation
    beta(1) = b(1)
    gamma(1) = d(1) / beta(1)
    For i = 2 To n
        beta(i) = b(i) - a(i) * c(i - 1) / beta(i - 1)
        gamma(i) = (d(i) - a(i) * gamma(i - 1)) / beta(i)
    Next i
    
'
' Back substitution.
    v(n) = gamma(n)
    For i = n - 1 To 1 Step -1
        v(i) = gamma(i) - c(i) * v(i + 1) / beta(i)
    Next i
    

End Sub


